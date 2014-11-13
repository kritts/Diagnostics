#include <jni.h>
#include "opencv2/core/core.hpp"
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <stdio.h>
#include <string>
#include <vector>
#include <android/log.h>

#include <algorithm>
#include <iostream>
#include <vector>

using namespace std;
using namespace cv;

extern "C" {
	JNIEXPORT jstring JNICALL Java_washington_edu_odk_diagnostics_ProcessImage_findCirclesNative(JNIEnv * env, jobject obj, jstring imagePath, jstring fileName);
 
	JNIEXPORT jstring JNICALL Java_washington_edu_odk_diagnostics_ProcessImage_findCirclesNative(JNIEnv * env, jobject obj, jstring imagePath, jstring fileName)
	 {

		const char *nativeString = env->GetStringUTFChars(imagePath, 0);

		Mat image = imread(nativeString, 0);
		Mat temp = image;
		Mat src = image;
		Mat channel[3];

		Mat output_final = image;

		// Blue channel of image
	    split(src, channel);
		Mat blue_channel = channel[0];

		int rows = blue_channel.rows;
		int cols = blue_channel.cols;

		int originalX = cols / 8;
		int originalY = rows * 3 / 8;
		int width = cols * 7 / 8 - originalX;
		int height = rows * 3 / 4 - rows * 2 / 8;


		// Roughly cropping the image
		Mat cropedImage = blue_channel(Rect(originalX, originalY, width, height));
		Mat original_cropped;

		src.copyTo(original_cropped);


		original_cropped = src(Rect(originalX, originalY, width, height));
		Mat croppedBlurred;


		output_final = output_final(Rect(originalX, originalY, width, height));

		// Blur the image
	    //GaussianBlur(cropedImage, croppedBlurred, Size(1, 1), 10.0);

		// Increase contrast
		//equalizeHist(croppedBlurred, croppedBlurred);

		// Additional threshold
		croppedBlurred = croppedBlurred > 100;

		// Make the image "black and white" by examining pixels over a certain intensity only (high threshold)
		threshold(cropedImage, croppedBlurred, // input and output
				  50,							  // treshold value
				  255,							  // max binary value
				  THRESH_BINARY | THRESH_OTSU);   // required flag to perform Otsu thresholding


		Mat output;
		int erosion_size = 3;
		Mat element = getStructuringElement(MORPH_CROSS, Size(2 * erosion_size + 1, 2 * erosion_size + 1), Point(erosion_size, erosion_size));
		Mat dilated;

		// Apply the erosion operation
		erode(croppedBlurred, croppedBlurred, element);
		dilate(croppedBlurred, croppedBlurred, element);

		// Finding contours
		// Thresholds
		int thresh = 50;
		int max_thresh = 255;
		RNG rng(12345);
		double area;

		Mat canny_output;
    	vector<vector<Point> > contours;
		vector<Vec4i> hierarchy;
		vector<Point> approx;

		// Detect edges using canny
		Canny(croppedBlurred, canny_output, thresh, thresh * 2, 3);

		// Find contours
		findContours(canny_output, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, Point(0, 0));

		// Draw contours
		Mat drawing = Mat::zeros(canny_output.size(), CV_8UC3);

		vector<vector<Point> > foundContours;

		for (int j = 0; j < contours.size(); j++) {
			area = contourArea(contours[j]);
			approxPolyDP(contours[j], approx, 5, true);

			if (area > 300) {

				__android_log_print(ANDROID_LOG_INFO, "COUNT", "AREA - %f",  area);
				Scalar color = Scalar(222, 20, 20);
                foundContours.push_back(contours[j]);
				drawContours(drawing, contours, j, Scalar(222, 20, 20), CV_FILLED);

				vector<Point>::iterator vertex;

				for (vertex = approx.begin(); vertex != approx.end(); ++vertex) {
					circle(original_cropped, *vertex, 3, Scalar(222, 20, 20), 1);
					}
				}
	    }

        vector<Point> averages;

		for (int j = 0; j < foundContours.size(); j++) {
			vector<Point> temp = foundContours[j];
            float sumX = 0.0;
            float sumY = 0.0;

			for(int k = 0; k < temp.size(); k++) {
				sumX += temp[k].x;
				sumY += temp[k].y;
			}
			Point current = Point(((float)sumX)/temp.size(), ((float)sumY)/temp.size());
            averages.push_back(current);

		}

		vector<vector<Point> > betterFits;
		// At this point, averages is a vector of Points
        for(int m = 0; m < averages.size() - 1; m++) {
        	for(int n = 0; n < averages.size(); n++) {
        		if (m != n) {
        		   Point one = averages.at(m);
        		   Point two = averages.at(n);

         		   double length = abs((double) (one.x - two.x));
                   double width = abs((double) (one.y - two.y));
                   std::vector<Point> v(2);
            //       v = { one, two };
            //       std::vector<Point> temp {};
        		}
        	}
        }

		int minSum = 10000;
		int maxSum = 0;
		int indexMin = 0;
		int indexMax = 0;

        for(int p = 0; p < averages.size(); p++) {
           Point current = averages.at(p);
           int sum = current.x + current.y;
           if(sum <= minSum) {
        	   minSum = sum;
        	   indexMin = p;

				__android_log_print(ANDROID_LOG_INFO, "min index", "current x and y - %d and %d",  current.x, current.y);
           }
           if(sum >= maxSum) {
        	   maxSum = sum;
        	   indexMax = p;
        	   __android_log_print(ANDROID_LOG_INFO, "max index", "current x and y - %d and %d",  current.x, current.y);
           }
        }

        Point minPoint = averages.at(indexMin);
        Point maxPoint = averages.at(indexMax);

        __android_log_print(ANDROID_LOG_INFO, "min_x min_y", "%d and %d",  minPoint.x, minPoint.y);
        __android_log_print(ANDROID_LOG_INFO, "max_x max_y", "%d and %d",  maxPoint.x, maxPoint.y);
        __android_log_print(ANDROID_LOG_INFO, "difference x and y", "%d and %d",  maxPoint.x - minPoint.x, maxPoint.y - minPoint.y);

		original_cropped = original_cropped(Rect(minPoint.x - 10, minPoint.y - 10, maxPoint.x - minPoint.x + 20, maxPoint.y - minPoint.y + 20));

		rectangle( original_cropped, Point( 300, 150 ), Point( 500, 200 ), Scalar( 0, 55, 255 ), 3, 4 );
		rectangle( original_cropped, Point( 530, 150 ), Point( 750, 200 ), Scalar( 0, 55, 255 ), 3, 4 );





        // Save images
		// TODO - Don't have these values hard coded in
	//	imwrite("/storage/emulated/0/Output/one.jpg", blue_channel);
	//	imwrite("/storage/emulated/0/Output/two.jpg", canny_output);
	//	imwrite("/storage/emulated/0/Output/three.jpg", croppedBlurred);
	//	imwrite("/storage/emulated/0/Output/four.jpg", drawing);
		imwrite("/storage/emulated/0/Output/six.jpg", original_cropped);


		return imagePath;
	 }
}


