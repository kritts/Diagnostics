#include <jni.h>
#include "opencv2/core/core.hpp"
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <stdio.h>
#include <string>
using namespace std;
using namespace cv;

extern "C" {
	JNIEXPORT jstring JNICALL Java_washington_edu_odk_diagnostics_ProcessImage_findCirclesNative(JNIEnv * env, jobject obj, jstring imagePath);
 
	JNIEXPORT jstring JNICALL Java_washington_edu_odk_diagnostics_ProcessImage_findCirclesNative(JNIEnv * env, jobject obj, jstring imagePath)
	 {
	//	Mat templImage, temp;
	//	templImage = imread(imagePath, 0);
	//	saveFeatures(templImage);
		return imagePath;
	 }
}


