#include <opencv/cv.h>
#include <opencv/cxcore.h>
#include "opencv2/highgui/highgui.hpp"

using namespace cv;

Mat dice, canny;

int main(int argc, const char** argv)
{
  // read in the dice image
  dice = imread(argv[1], 0);

  //Canny(dice, canny, 150, 350);
  Canny(dice, canny, 75, 250);

  int num = 0;

  // iterate through the edges and keep a count
  // fill each enclosed edge, if the area is too large then it's not a pip
  // if the area filled is between a certain tolerance then assume it's a pip
  for(int y=0;y<canny.size().height;y++)
  {
    uchar *row = canny.ptr(y);
    for(int x=0;x<canny.size().width;x++)
    {
      if(row[x] <= 128)
      {
        int area = floodFill(canny, Point(x,y), CV_RGB(255,255,255));
        if(area>7 && area < 50) num++;
      }
    }
  }
  printf("%d\n", num);
  return 0;
}
