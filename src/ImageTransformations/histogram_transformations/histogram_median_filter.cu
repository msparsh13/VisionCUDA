/**
 * Histogram-based median filter (CPU implementation)
 * Uses column histograms for sliding window median computation
 * its Complexity not dependant upon kernel size. (n*m*256)
 */

#include <vector>

using std::vector;

static unsigned char getMedian(const int* hist, int target)
{
    int count = 0;

    for (int i = 0; i < 256; i++)
    {
        count += hist[i];

        if (count >= target)
            return (unsigned char)i;
    }

    return 255;
}

void histogram_median_rgb(unsigned char* img, int width, int height, int k)
{
    int N = width * height;
    int r = k / 2;

    vector<unsigned char> out(3 * N);

    vector<int> colR(width * 256, 0); //histogram for each width just like [] we save in it
    vector<int> colG(width * 256, 0);
    vector<int> colB(width * 256, 0);

    vector<int> histR(256, 0);
    vector<int> histG(256, 0);
    vector<int> histB(256, 0);

    // initialize column histograms
    for (int x = 0; x < width; x++)
    {
        for (int y = 0; y < k && y < height; y++)
        {
            int idx = (y * width + x) * 3;

            colR[x * 256 + img[idx + 0]]++;
            colG[x * 256 + img[idx + 1]]++;
            colB[x * 256 + img[idx + 2]]++;
        }
    }

    // this is just sliding window dont worry
    // we are add for each x new in window getting its window then subtracting each x
    for (int y = r; y < height - r; y++)
    {
        std::fill(histR.begin(), histR.end(), 0);
        std::fill(histG.begin(), histG.end(), 0);
        std::fill(histB.begin(), histB.end(), 0);

        // build histogram from first k columns
        for (int x = 0; x < k && x < width; x++)
        {
            for (int i = 0; i < 256; i++)
            {
                histR[i] += colR[x * 256 + i];
                histG[i] += colG[x * 256 + i];
                histB[i] += colB[x * 256 + i];
            }
        }

        for (int x = r; x < width - r; x++)
        {
            int target = (k * k) / 2 + 1;

            unsigned char r_med = getMedian(histR.data(), target);
            unsigned char g_med = getMedian(histG.data(), target);
            unsigned char b_med = getMedian(histB.data(), target);

            int out_idx = (y * width + x) * 3;

            out[out_idx + 0] = r_med;
            out[out_idx + 1] = g_med;
            out[out_idx + 2] = b_med;

            if (x + r + 1 < width)
            {
                int left  = x - r;
                int right = x + r + 1;

                for (int i = 0; i < 256; i++)
                {
                    histR[i] -= colR[left * 256 + i];
                    histR[i] += colR[right * 256 + i];

                    histG[i] -= colG[left * 256 + i];
                    histG[i] += colG[right * 256 + i];

                    histB[i] -= colB[left * 256 + i];
                    histB[i] += colB[right * 256 + i];
                }
            }
        }

        // update column histograms for next row
        if (y + r + 1 < height)
        {
            for (int x = 0; x < width; x++)
            {
                int remove_idx = ((y - r) * width + x) * 3;
                int add_idx    = ((y + r + 1) * width + x) * 3;

                colR[x * 256 + img[remove_idx + 0]]--;
                colR[x * 256 + img[add_idx + 0]]++;

                colG[x * 256 + img[remove_idx + 1]]--;
                colG[x * 256 + img[add_idx + 1]]++;

                colB[x * 256 + img[remove_idx + 2]]--;
                colB[x * 256 + img[add_idx + 2]]++;
            }
        }
    }

    std::memcpy(img, out.data(), 3 * N);
}
