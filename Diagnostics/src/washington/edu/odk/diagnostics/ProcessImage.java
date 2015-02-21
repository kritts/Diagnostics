package washington.edu.odk.diagnostics;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import android.util.Log; 

import java.util.Arrays;  

import android.os.Bundle;
import android.os.Environment;

import java.io.InputStream;

import com.androidplot.xy.*; 

import android.content.Intent; 
import android.webkit.WebView;  

import java.io.BufferedReader; 

import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.Matrix;

import java.io.FileInputStream; 

import android.graphics.Bitmap;  

import java.io.InputStreamReader;  
import java.nio.channels.FileChannel;

import org.opencv.android.OpenCVLoader;  
import org.opencv.android.BaseLoaderCallback;  

import android.support.v7.app.ActionBarActivity; 

import org.opencv.android.LoaderCallbackInterface; 

//TODO Things to add :
       // Error messages when they are problems 
	   // Save data- from all three colums
	   // 


// File structure created: 
// 		/storage/emulated/0/Diagnostics_Images is the primary folder with all of the content 
//      /storage/emulated/0/Diagnostics_Images/ProcessedImages/*.jpg have processed images 
// 	    /storage/emulated/0/Diagnostics_Images/ProcessedData/*.txt has data from the test strips 

// Naming convention for images: 
//      - Image taken on the device
//			- .jpg	 -> 	MRSA_data_time.jpg
//			- .txt 	 -> 	MRSA_data_time.txt
// 		- Image chosen from saved file on the device
//			- .jpg	 -> 	MRSA_originalFileName.jpg
// 			- .txt 	 -> 	MRSA_originalFileName.txt

/** This file runs NDK code to process the chosen image */ 
public class ProcessImage extends ActionBarActivity {
	private static final String TAG = "ProcessImage";

	/** Used to show the users chosen image.*/
	private Bitmap bitmap = null;
	 
	/** True if OpenCV has been initialized, false otherwise. */
	private boolean mOpenCVInitiated = false;
	
	/** Path of the chosen image. */
	private String path;

	/** If resultCode == 1, image was just taken. 
	 *  If resultCode == 2, a local image from the device was chosen. */
	private int resultCode;
	
	/** C++ code to process image */
	public native String findCirclesNative(String imagePath, String fileName);
	 
	private String mFileName;
	
	/** Called when the activity is first created. */
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_process_image);
		 
		// Initialize OpenCV
		OpenCVLoader.initAsync(OpenCVLoader.OPENCV_VERSION_2_4_3, this, mLoaderCallback);
         
		Intent intent = getIntent();
		Bundle extras = intent.getExtras();  
		path  = extras.getString("path");  			//TODO: Make sure absolute path;  
		resultCode = extras.getInt("resultCode");
    
		File src = new File(path);
		mFileName = src.getName(); 
		
		File dest = new File(Environment.getExternalStorageDirectory().getAbsolutePath() + "/Diagnostics_Images/Original_Images/" + src.getName());
		 
		FileChannel source = null;
        FileChannel destination = null;
        try {
			source = new FileInputStream(src).getChannel();
			destination = new FileOutputStream(dest).getChannel();
	        if (destination != null && source != null) {
	            destination.transferFrom(source, 0, source.size());
	        }
	        if (source != null) {
	            source.close();
	        }
	        if (destination != null) {
	            destination.close();
	        }
		} catch (FileNotFoundException e) { 
			e.printStackTrace();
		} catch (IOException e) { 
			e.printStackTrace();
		}
         
		Log.e(TAG, mFileName);
		
		if(resultCode == 2) {
			path = Environment.getExternalStorageDirectory().getAbsolutePath() + "Diagnostics_Images" + path;  // TODO: Make sure this is correct
		}  
	}
	 
	private void storeImage(Bitmap image, String path) {
	    File pictureFile = new File(path);
	    try {
	        FileOutputStream fos = new FileOutputStream(pictureFile);
	        image.compress(Bitmap.CompressFormat.PNG, 90, fos);
	        fos.close();
	    } catch (FileNotFoundException e) {
	        Log.d(TAG, "File not found: " + e.getMessage());
	    } catch (IOException e) {
	        Log.d(TAG, "Error accessing file: " + e.getMessage());
	    }  
	}
		
	/** Called after OpenCV is initialized. Processes the chosen image if it is 
	 *  a valid image */	
	private void showImageAndPlot() { 
		String location = Environment.getExternalStorageDirectory().getAbsolutePath() + "/Diagnostics_Images/";
		 
		boolean okay = true;
		
		
		
		// Java native function - processes the image 
		String output_path = findCirclesNative(location, this.mFileName);  // TODO - should modify okay variable 
		 
		
		if(okay) {
			path = "/storage/emulated/0/Diagnostics_Images/ProcessedImages/" + "six.jpg";		// TODO - change to path
			
			
			String html =   "<html>"
					        + "<body bgcolor=\"White\">" 
	                        +    "<center> "
	                        +       "<img src=\"file:///" + path + "\" width=\"100%\"" + "> "
	                        +     "</center>"
	                        + "</body>" 
	                     + "</html>";
			 
			WebView myWebView = (WebView)this.findViewById(R.id.webview);

			myWebView.loadDataWithBaseURL(null, html, "text/html", "utf-8", null); 
			myWebView.getSettings().setBuiltInZoomControls(true);
			myWebView.getSettings().setUseWideViewPort(true);
			myWebView.getSettings().setLoadWithOverviewMode(true);
			
			plotData(); // should take a string - path of the file 
			
		} else {  
		 // Show error message;
		} 
	}

	/**  */
	private void plotData() {
		String value;
		try {
			value = getStringFromFile("/storage/emulated/0/Output/output.txt"); // TODO
		} catch (Exception e) { 
			value = "";
			Log.e(TAG, e.toString());
			e.printStackTrace();
		} 
		 
		String[] values = value.split("\n"); 
		Number[] doubles = new Number[values.length];
		
		for (int i = 0; i < values.length; i++) {
		    doubles[i] = Double.parseDouble(values[i]);
		}
		
		Number[] series1Numbers = doubles; 
		
		XYPlot mySimpleXYPlot = (XYPlot) findViewById(R.id.mySimpleXYPlot);
		mySimpleXYPlot.getGraphWidget().getGridBackgroundPaint().setColor(Color.WHITE);

		XYSeries series1 = new SimpleXYSeries(
				Arrays.asList(series1Numbers),          // SimpleXYSeries takes a List so turn our array into a List
				SimpleXYSeries.ArrayFormat.Y_VALS_ONLY, // Y_VALS_ONLY means use the element index as the x value
				"Series1");                             // Set the display title of the series
	  
		// Format graph
		LineAndPointFormatter series1Format = new LineAndPointFormatter(
	            Color.rgb(0, 0, 0),                  	 // line color
	            Color.rgb(0, 0, 0),                		 // point color
	            Color.rgb(34, 139, 34), null);           // fill color 
		 
		// Customizing the plot	
        mySimpleXYPlot.addSeries(series1, series1Format);  
        mySimpleXYPlot.getGraphWidget().getGridBackgroundPaint().setColor(Color.WHITE); 
        mySimpleXYPlot.getGraphWidget().getDomainOriginLinePaint().setColor(Color.BLACK);
        mySimpleXYPlot.getGraphWidget().getRangeOriginLinePaint().setColor(Color.BLACK); 
        // TODO - ask plot axis labels 
        // TODO - get rid of legend 
	}

	// Given a string of a filepath returns the contens of the file as a string 
	public static String getStringFromFile(String filePath) throws Exception {
	    File fl = new File(filePath);
	    FileInputStream fin = new FileInputStream(fl);
	    String ret = convertStreamToString(fin); 
	    fin.close();        
	    return ret;
	}
	 
	// Given an input stream returns the contents as a string 
	public static String convertStreamToString(InputStream is) throws Exception {
	    BufferedReader reader = new BufferedReader(new InputStreamReader(is));
	    StringBuilder sb = new StringBuilder();
	    String line = null;
	    while ((line = reader.readLine()) != null) {
	      sb.append(line).append("\n");
	    }
	    reader.close();
	    return sb.toString();
	}
	
    private BaseLoaderCallback  mLoaderCallback = new BaseLoaderCallback(this) {
        @Override
        public void onManagerConnected(int status) {
            switch (status) {
                case LoaderCallbackInterface.SUCCESS: {
                	mOpenCVInitiated = true; 
                    // Load native library after OpenCV initialization
                    System.loadLibrary("process_image");
                    Log.i(TAG, "OpenCV loaded successfully"); 
                    showImageAndPlot(); 
                } break;
                default: {
                    super.onManagerConnected(status);
                } break;
            }
        }
    };  
}
