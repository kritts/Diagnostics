// Krittika D'Silva
// krittika.dsilva@gmail.com

// This code processes images of test strips for MRSA Diagnosis.

#include <jni.h>
#include "opencv2/core/core.hpp"
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <stdio.h>
#include <string>
#include <vector>
#include <android/log.h>

#include <fstream>
#include <algorithm>
#include <iostream>
#include <vector>

// Note the image is being rotated 360 degrees - not 90 at the moment
using namespace std;
using namespace cv;

extern "C" {
	JNIEXPORT jstring JNICALL Java_washington_edu_capstone_ProcessImage_findCirclesNative(JNIEnv * env, jobject obj, jstring imagePath, jstring fileName, jstring nameWOExtension);

	JNIEXPORT jstring JNICALL Java_washington_edu_capstone_ProcessImage_findCirclesNative(JNIEnv * env, jobject obj, jstring imagePath, jstring fileName, jstring nameWOExtension)
	{

		// Get string in a format that we can use it
		const char *nativeString = env->GetStringUTFChars(imagePath, 0);
		const char *nativeName = env->GetStringUTFChars(fileName, 0);
		// Folder for original images
		std::ostringstream oss;
		oss << nativeString << "Original_Images/" << nativeName;
		std::string name = oss.str();

		 // Original read in image, since flag (1) is > 0 return a 3-channel color image.
		Mat original_image = imread(name, 1);

		// Rotate image - 90 degrees
		transpose(original_image, original_image);
	    flip(original_image, original_image, -1);

		__android_log_print(ANDROID_LOG_ERROR, "C++ Code", "Rotated Image.");

		// Grayscale image
		Mat image = imread(name, 1);
		transpose(image, image);
		flip(image, image, -1);

		Mat src = image;

		Mat channel[3];
	    split(image, channel);
	    // Green channel of image
	   	Mat green_channel = channel[1];

		// Height and width of the original picture
		int rows = green_channel.rows;
		int cols = green_channel.cols;

		__android_log_print(ANDROID_LOG_ERROR, "C++ Code", "Looked at green channel.");

		// Cropping the image slightly 								TODO: Might have to update these
		int originalX = cols / 8;
		int originalY = rows * 3 / 8;
		int width = cols * 7 / 8 - originalX;
		int height = rows * 3 / 4 - rows * 2 / 8;

		__android_log_print(ANDROID_LOG_ERROR, "C++ Code", "Cropped image.");
		// Roughly cropping the image
		Mat croppedImage = green_channel(Rect(originalX, originalY, width, height));
        Mat croppedBlurred;

		original_image = original_image(Rect(originalX, originalY, width, height));
		__android_log_print(ANDROID_LOG_ERROR, "C++ Code", "Cropped original image.");


		// Blur the image
	    //GaussianBlur(croppedImage, croppedBlurred, Size(1, 1), 10.0);

		// Increase contrast
		//equalizeHist(croppedBlurred, croppedBlurred);

		// Additional threshold
		//croppedImage = croppedImage > 100;
		// Make the image "black and white" by examining pixels over a certain intensity only (high threshold)
				threshold(croppedImage, croppedBlurred, // input and output
				  50,							  // treshold value
				  255,							  // max binary value
				  THRESH_BINARY | THRESH_OTSU);   // required flag to perform Otsu thresholding


		__android_log_print(ANDROID_LOG_ERROR, "C++ Code", "Checking above threshold value.");

		// Parameters
		int erosion_size = 3;
		Mat element = getStructuringElement(MORPH_CROSS, Size(2 * erosion_size + 1, 2 * erosion_size + 1), Point(erosion_size, erosion_size));

		// Apply the erosion operation
		erode(croppedBlurred, croppedBlurred, element);
		dilate(croppedBlurred, croppedBlurred, element);

		__android_log_print(ANDROID_LOG_ERROR, "C++ Code", "Finding fiducials.");
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

		__android_log_print(ANDROID_LOG_ERROR, "C++ Code", "Drawing contours");

		vector<vector<Point> > foundContours;

		for (int j = 0; j < contours.size(); j++) {
			area = contourArea(contours[j]);
			approxPolyDP(contours[j], approx, 5, true);
			if (area > 300 && area < 1500) {									// TODO
				__android_log_print(ANDROID_LOG_ERROR, "C++ Code - v5", "%f",  area);
				Scalar color = Scalar(222, 20, 20);
                foundContours.push_back(contours[j]);
				drawContours(drawing, contours, j, Scalar(222, 20, 20), CV_FILLED);

				vector<Point>::iterator vertex;
				for (vertex = approx.begin(); vertex != approx.end(); ++vertex) {
					circle(original_image, *vertex, 3, Scalar(222, 20, 20), 1);
					}
			}
	    }

		__android_log_print(ANDROID_LOG_ERROR, "C++ Code", "Averaging contours");
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

		__android_log_print(ANDROID_LOG_ERROR, "C++ Code", "Checking lengths.");
/*
		// At the moment, this doesn't do anything
		// It's purpose is to find spots that are the best fit - by looking at the
		// area created by the four points.
		vector<vector<Point> > betterFits;
        for(int m = 0; m < averages.size() - 1; m++) {
        	for(int n = 0; n < averages.size(); n++) {
        		if (m != n) {
        		   Point one = averages.at(m);
        		   Point two = averages.at(n);

         		   double length = abs((double) (one.x - two.x));
                   double width = abs((double) (one.y - two.y));
                   std::vector<Point> v(2);
        		}
        	}
        }
*/
		int minSum = 10000;
		int maxSum = 0;
		int indexMin = 0;
		int indexMax = 0;


		__android_log_print(ANDROID_LOG_ERROR, "C++ Code", "Starting min/max index checks.");

        for(int p = 0; p < averages.size(); p++) {
           Point current = averages.at(p);
           int sum = current.x + current.y;
           if(sum <= minSum) {
        	   minSum = sum;
        	   indexMin = p;

				__android_log_print(ANDROID_LOG_ERROR, "min index", "current x and y - %d and %d",  current.x, current.y);
           }
           if(sum >= maxSum) {
        	   maxSum = sum;
        	   indexMax = p;
        	   __android_log_print(ANDROID_LOG_ERROR, "max index", "current x and y - %d and %d",  current.x, current.y);
           }
        }

		__android_log_print(ANDROID_LOG_ERROR, "C++ Code - v2", "Finished min/max index checks.");
        // Point at the upper left
        Point minPoint = averages.at(indexMin);
        // Point at the lower right
        Point maxPoint = averages.at(indexMax);

        // Problem here TODO
        original_image = original_image(Rect(minPoint.x - 20, minPoint.y - 20, minPoint.x + 1100, minPoint.y + 250));

        Mat stdDark;
        original_image.copyTo(stdDark);

        Mat stdWhite;
        original_image.copyTo(stdWhite);

        Mat copyOne;
        original_image.copyTo(copyOne);

        Mat copyTwo;
        original_image.copyTo(copyTwo);

        // horizontal
	 	rectangle( original_image, Point( 550, 100 ), Point( 650, 250 ), Scalar( 0, 55, 255 ), 3, 4 );
		rectangle( original_image, Point( 900, 100 ), Point( 1000, 250 ), Scalar( 0, 55, 255 ), 3, 4 );

		__android_log_print(ANDROID_LOG_ERROR, "C++ Code - v1", "Setting locations of rectangles");

		// vertical
		//rectangle( original_image, Point( 385, 30 ), Point( 415, 350 ), Scalar( 0, 55, 255 ), 1, 4 );
		//rectangle( original_image, Point( 635, 30 ), Point( 665, 350 ), Scalar( 0, 55, 255 ), 1, 4 );

		// color standard, dark
		//rectangle( original_image, Point( 190, 50 ), Point( 200, 60 ), Scalar( 0, 55, 255 ), 1, 4 );
		// color standard, white
		//rectangle( original_image, Point( 120, 50 ), Point( 130, 60 ), Scalar( 0, 55, 255 ), 1, 4 );

		// dark color standard
		//Rect darkStd(Point(190, 50), Point(200, 60));
		//stdDark = stdDark(darkStd);

		// white color standard
		//Rect whiteStd(Point( 120, 50 ), Point( 130, 60 ));
		//stdWhite = stdWhite(whiteStd);

		// first test strip
 		Rect colorFirst(Point( 400, 150 ), Point( 450, 220 ));
	 	copyOne = copyOne(colorFirst);

		// second test strip
        Rect colorSecond(Point( 650, 150 ), Point( 700, 220 ));
         copyTwo = copyTwo(colorSecond);

        __android_log_print(ANDROID_LOG_ERROR, "C++ Code - v1", "Found locations of test strips.");


		std::ostringstream oss_third;
		oss_third << nativeString << "Processed_Data/" << nameWOExtension << ".txt";
		std::string name_third = oss_third.str();

		 __android_log_print(ANDROID_LOG_ERROR, "C++ Code - v1", "%s ",  name_third.c_str());

        Scalar avgDark = cv::mean(stdDark);
        Scalar avgWhite = cv::mean(stdWhite);

        // we can to look @ red color channel - not sure if this is acheiving what we want
        double valDark = avgDark.val[0];
        double valWhite = avgWhite.val[1]; // is 0 red? // not sure if this is right TODO

        ofstream outputFile;
        outputFile.open (name_third); // TODO

        // copyOne & copyTwo
        for(int r = 0; r < copyOne.rows; r++) {
        	double current = 0.0;
        	for(int s = 0; s < copyOne.cols; s++) {
        		Vec3b tempColor = copyOne.at<Vec3b>(Point(s,r));
        		//__android_log_print(ANDROID_LOG_ERROR, "C++ Code", "avg %d", tempColor[0]);
        		current += tempColor[0];
        	}
        	current = current / (double) copyOne.cols;
    	//	__android_log_print(ANDROID_LOG_ERROR, "C++ Code", "avg %d", current);
        	current = (current - valDark) / (valWhite - valDark);
    		__android_log_print(ANDROID_LOG_ERROR, "C++ Code", "VALUE OF INT %f", current);
    		outputFile << current;
    		outputFile << "\n";
        }

        __android_log_print(ANDROID_LOG_ERROR, "C++ Code", "WHITE BLACK %f %f", valDark, valWhite);

        outputFile.close();


		const char *nativeString_2 = env->GetStringUTFChars(imagePath, 0);
		const char *nativeName_2 = env->GetStringUTFChars(fileName, 0);

		// Folder for processed images
		std::ostringstream oss_second;
		oss_second << nativeString_2 << "Processed_Images/" << nativeName_2;
		std::string name_second = oss_second.str();

		__android_log_print(ANDROID_LOG_ERROR, "C++ Code", "%s", name_second.c_str());
        // Save images
		imwrite(name_second, original_image); // TODO

		__android_log_print(ANDROID_LOG_ERROR, "C++ Code", "Done - 1!");
		return imagePath;
	 }
}


