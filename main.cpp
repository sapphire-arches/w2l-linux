#include <cassert>
#include <cstdio>
#include <cstring>
#include <cmath>

#include <array>
#include <iostream>
#include <vector>

#include <fvad.h>

#include <pulse/simple.h>
#include <pulse/error.h>

#include "w2l.h"

#define BUFSIZE 480
#define PRE_ACTIVITY_BUFSIZE (BUFSIZE * 4)
#define POST_ACTIVITY_BUFSIZE (BUFSIZE * 4)

typedef int16_t sample_storage;

class PASimpleContainer {
  public:
    std::array<sample_storage, BUFSIZE> m_buf;

    enum class Direction {
      RECORD, PLAYBACK
    };

    PASimpleContainer(const char * filename, Direction direction) {
      static const pa_sample_spec ss = {
        .format = PA_SAMPLE_S16LE,
        .rate = 16000,
        .channels = 1,
      };

      int error;

      auto dirspec = direction == Direction::RECORD ? PA_STREAM_RECORD : PA_STREAM_PLAYBACK;

      if (!(m_simple = pa_simple_new(nullptr, filename, dirspec, nullptr, "w2l-record", &ss, nullptr, nullptr, &error))) {
        fprintf(stderr, __FILE__": pa_simple_new failed: %s\n", pa_strerror(error));
        throw "Failed to initialize PulseAudio";
      }
    }

    ~PASimpleContainer() {
      pa_simple_free(m_simple);
    }

    void process() {
      int error;
      if (pa_simple_read(m_simple, m_buf.data(), m_buf.size() * sizeof(sample_storage), &error) < 0) {
        fprintf(stderr, __FILE__": pa_simple_read() failed: %s\n", pa_strerror(error));
        throw "Failed to read from PA stream";
      }
    }

    void play(std::vector<float> & samples) {
      std::vector<sample_storage> data(samples.size());
      data.insert(data.begin(), samples.begin(), samples.end());

      int error;
      if (pa_simple_write(m_simple, data.data(), data.size() * sizeof(data[0]), &error) < 0) {
        fprintf(stderr, __FILE__": pa_simple_write() failed: %s\n", pa_strerror(error));
      }
    }

  private:
    pa_simple *m_simple;

    PASimpleContainer() = delete;
    PASimpleContainer(const PASimpleContainer&) = delete;
    PASimpleContainer & operator=(const PASimpleContainer&) = delete;
    PASimpleContainer(const PASimpleContainer&&) = delete;
    PASimpleContainer & operator=(const PASimpleContainer&&) = delete;
};

class FVadContainer {
  public:
    FVadContainer() {
      m_vad = fvad_new();
      fvad_set_sample_rate(m_vad, 16000);
    }

    ~FVadContainer() {
      fvad_free(m_vad);
    }

    template<std::size_t N>
    bool contains_activity(std::array<sample_storage, N> & buffer) {
      int vad = fvad_process(m_vad, buffer.data(), N);
      if (vad < 0) {
        fprintf(stderr, __FILE__": fvad_process failed: %d\n", vad);
        throw "Failed to run fvad process";
      }

      return !!vad;
    }

  private:
    Fvad *m_vad;

    FVadContainer(const FVadContainer&) = delete;
    FVadContainer & operator=(const FVadContainer&) = delete;
    FVadContainer(const FVadContainer&&) = delete;
    FVadContainer & operator=(const FVadContainer&&) = delete;
};

class Wav2LetterContainer {
  public:
    Wav2LetterContainer(const char * am_path, const char * tokens_path, const char * lm_path, const char * lexicon_path) {
      m_engine = w2l_engine_new(am_path, tokens_path);
      m_decoder = w2l_decoder_new(m_engine, lm_path, lexicon_path);
    }

    ~Wav2LetterContainer() {
      w2l_decoder_free(m_decoder);
      w2l_engine_free(m_engine);
    }

    char * process(std::vector<float> data) {
      w2l_emission *emission = w2l_engine_process(m_engine, data.data(), data.size());
      return w2l_decoder_decode(m_decoder, emission);
    }
  private:
    w2l_engine * m_engine;
    w2l_decoder * m_decoder;
};

class ClipBuffer {
  public:
    ClipBuffer(PASimpleContainer & pulse, Wav2LetterContainer & engine) :
      m_pulse(pulse),
      m_engine(engine),
      m_pre_activity_buffer_start(0),
      m_post_activity_buffer_size(0),
      m_last_active(false) {
      assert(PRE_ACTIVITY_BUFSIZE % BUFSIZE == 0);
    }

    void handle_frame(std::array<sample_storage, BUFSIZE> & buffer, bool is_active) {
      if (is_active) {
        if (!m_last_active) {
          std::cout << "New activity detected" << std::endl;
        }
        if (m_post_activity_buffer_size != 0) {
          // We were in the middle of collecting the last few frames, dump those
          // into the clip buffer before the new data
          m_clip_buffer.reserve(m_clip_buffer.size() + m_post_activity_buffer_size);
          auto pab_end = std::begin(m_post_activity_buffer) + m_post_activity_buffer_size;
          m_clip_buffer.insert(std::end(m_clip_buffer), std::begin(m_post_activity_buffer), pab_end);
          m_post_activity_buffer_size = 0;
        }
        m_clip_buffer.reserve(m_clip_buffer.size() + buffer.size());
        m_clip_buffer.insert(std::end(m_clip_buffer), std::begin(buffer), std::end(buffer));
      } else {
        if (m_last_active || m_post_activity_buffer_size != 0) {
          // There was some activity during the last frame, or we're in the post activity skid
          if (m_post_activity_buffer_size == m_post_activity_buffer.size()) {
            // We've completed the frame. Flatten everything to a float vector
            // and throw it at w2l
            if (m_clip_buffer.size() > 8000) {
              std::vector<float> w2lin(m_pre_activity_buffer.size() + m_clip_buffer.size() + m_post_activity_buffer.size());
              auto pre_activity_begin = std::begin(m_pre_activity_buffer) +
                  ((m_pre_activity_buffer_start + m_pre_activity_buffer.size() - buffer.size()) % m_pre_activity_buffer.size());
              w2lin.insert(std::end(w2lin), pre_activity_begin, std::end(m_pre_activity_buffer));
              w2lin.insert(std::end(w2lin), std::begin(m_clip_buffer), std::end(m_clip_buffer));
              w2lin.insert(std::end(w2lin), std::begin(m_post_activity_buffer), std::end(m_post_activity_buffer));

              // Normalize input buffer
              float max_mag = 0.0;
              for (auto & f : w2lin) {
                float a = fabs(f);
                if (a > max_mag) {
                  max_mag = a;
                }
              }
              std::cout << "Normalizing floats by dividing by " << max_mag << std::endl;
              for (auto & f : w2lin) {
                f /= max_mag;
              }

              std::cout << "Submit buffer of length " << w2lin.size() << std::endl;

              char * res = m_engine.process(w2lin);
              m_pulse.play(w2lin);
              std::cout << res << std::endl;

              free(res);
            } else {
              std::cout << "Not submitting buffer: too short" << std::endl;
            }
            m_post_activity_buffer_size = 0;
            m_clip_buffer.clear();
          } else {
            std::copy(
                std::begin(buffer),
                std::end(buffer),
                std::begin(m_post_activity_buffer) + m_post_activity_buffer_size);
            m_post_activity_buffer_size += buffer.size();
          }
        } else {
          // copy into the rolling pre-activity buffer
          std::copy(
              std::begin(buffer), std::end(buffer),
              std::begin(m_pre_activity_buffer) + m_pre_activity_buffer_start
          );
          m_pre_activity_buffer_start = (m_pre_activity_buffer_start + buffer.size()) %  m_pre_activity_buffer.size();
        }
      }
      m_last_active = is_active;
    }

  private:
    Wav2LetterContainer & m_engine;
    PASimpleContainer & m_pulse;

    std::array<sample_storage, PRE_ACTIVITY_BUFSIZE> m_pre_activity_buffer;
    size_t m_pre_activity_buffer_start;

    std::array<sample_storage, POST_ACTIVITY_BUFSIZE> m_post_activity_buffer;
    size_t m_post_activity_buffer_size;

    std::vector<sample_storage> m_clip_buffer;

    bool m_last_active;
};

int main(int argc, const char ** argv) {
  std::cout << "hello, world" << std::endl;

  if (argc < 5) {
    fprintf(stderr, "Usage:\n");
    fprintf(stderr, "    %s <am.bin> <tokens.txt> <lm.bin> <lexicon.bin>\n", argv[0]);
    return -1;
  }

  PASimpleContainer pa_rec(argv[0], PASimpleContainer::Direction::RECORD);
  PASimpleContainer pa_play(argv[0], PASimpleContainer::Direction::PLAYBACK);
  FVadContainer fv;
  Wav2LetterContainer w2l(argv[1], argv[2], argv[3], argv[4]);

  ClipBuffer clip_buffer(pa_play, w2l);

  for (;;) {
    pa_rec.process();
    bool valid = fv.contains_activity(pa_rec.m_buf);

    clip_buffer.handle_frame(pa_rec.m_buf, valid);
  }

  return 0;
}
