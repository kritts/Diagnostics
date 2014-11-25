package washington.edu.odk.diagnostics;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;

import android.util.Log; 
import android.os.Bundle; 
import android.content.Intent;
import android.graphics.Bitmap; 
import android.webkit.WebView;
import android.widget.ImageView;
import android.graphics.BitmapFactory;

import org.opencv.android.OpenCVLoader;  
import org.opencv.android.BaseLoaderCallback;

import android.support.v7.app.ActionBarActivity;

import org.opencv.android.LoaderCallbackInterface;

import com.androidplot.xy.*;

import java.util.Arrays;




// This file runs NDK code to process the chosen image 
public class ProcessImage extends ActionBarActivity {
	private static final String TAG = "ProcessImage";

	/** Used to show the users chosen image.*/
	private Bitmap bitmap = null;
	
	private ImageView im;
	
	private boolean mOpenCVInitiated = false;
	
	private String path;

	private int resultCode;
	
	public native String findCirclesNative(String imagePath, String fileName);
	 
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_process_image);
		
		im = (ImageView) findViewById(R.id.image);
		
		OpenCVLoader.initAsync(OpenCVLoader.OPENCV_VERSION_2_4_3, this, mLoaderCallback);
         
		Intent intent = getIntent();
		Bundle extras = intent.getExtras();  
		path  = extras.getString("path");  //TODO: Make sure absolute path;  
		resultCode = extras.getInt("resultCode");
		
		if(resultCode == 2) {
			path = "/storage/emulated/0" + "/Diagnostics_Images" + path;
			Log.e(TAG, path);
		}
		Log.e(TAG, path);
		
	}
		
	
	private void setImage() {  
		File temp = new File(path);
		String two = temp.getName();
		String output_path = findCirclesNative(path, two); 
		path = "/storage/emulated/0/Output/six.jpg";
		
		
		String html =   "<html>"
				        + "<body bgcolor=\"White\">" 
                        +    "<center> "
                        +       "<img src=\"file:///" + path + "\" width=\"100%\"" + "> "
                        +     "</center>"
                        + "</body>" 
                     + "</html>";
		Log.e(TAG, html);
		 

		WebView myWebView = (WebView)this.findViewById(R.id.webview);

		myWebView.loadDataWithBaseURL(null, html, "text/html", "utf-8", null); 
		myWebView.getSettings().setBuiltInZoomControls(true);
		myWebView.getSettings().setUseWideViewPort(true);
		myWebView.getSettings().setLoadWithOverviewMode(true);
		
		String value;
		try {
			value = getStringFromFile("/storage/emulated/0/Output/output.txt");
		} catch (Exception e) { 
			value = "";
			e.printStackTrace();
		} 
		String[] values = value.split("\n");
		
		Number[] doubles = new Number[values.length];
		
		for (int i = 0; i < values.length; i++) {
		    doubles[i] = Double.parseDouble(values[i]);
		}
		
		
		Number[] series1Numbers = doubles;
		
		
		Log.e(TAG, "!!!!!!!!!!!!!!!!!");
		Log.e(TAG, "" + value.length());
		 
		XYPlot mySimpleXYPlot = (XYPlot) findViewById(R.id.mySimpleXYPlot);
		
		XYSeries series1 = new SimpleXYSeries(
				Arrays.asList(series1Numbers),          // SimpleXYSeries takes a List so turn our array into a List
				SimpleXYSeries.ArrayFormat.Y_VALS_ONLY, // Y_VALS_ONLY means use the element index as the x value
				"Series1");                             // Set the display title of the series
	
		LineAndPointFormatter series1Format = new LineAndPointFormatter();
     //   series1Format.setPointLabelFormatter(new PointLabelFormatter());
		 // add a new series' to the xyplot:
        mySimpleXYPlot.addSeries(series1, series1Format);
	
	
	}
		 
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

	public static String getStringFromFile (String filePath) throws Exception {
	    File fl = new File(filePath);
	    FileInputStream fin = new FileInputStream(fl);
	    String ret = convertStreamToString(fin);
	    //Make sure you close all streams.
	    fin.close();        
	    return ret;
	}
	
	
	
    private BaseLoaderCallback  mLoaderCallback = new BaseLoaderCallback(this) {
        @Override
        public void onManagerConnected(int status) {
            switch (status) {
                case LoaderCallbackInterface.SUCCESS:
                {
                	mOpenCVInitiated = true; 
                    // Load native library after OpenCV initialization
                    System.loadLibrary("process_image");
                    Log.i(TAG, "OpenCV loaded successfully");

                    setImage();
                    
                } break;
                default:
                {
                    super.onManagerConnected(status);
                } break;
            }
        }
    }; 
    	
	
	/** Minimizes size of the bitmap so that it can be displayed in the app. */ 
	private Bitmap halfSize(Bitmap input) { 
		int height = input.getHeight();
		int width = input.getWidth();  
		return Bitmap.createScaledBitmap(input,  width/2, height/2, false);
	}
}
