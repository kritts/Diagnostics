package washington.edu.odk.diagnostics;

import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;

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
		
		
		FileInputStream fis;
		final StringBuffer storedString = new StringBuffer();

		try {
		    fis = openFileInput("/storage/emulated/0/Output/output.txt");
		    DataInputStream dataIO = new DataInputStream(fis);
		    String strLine = null;

		    if ((strLine = dataIO.readLine()) != null) {
		        storedString.append(strLine);
		    }

		    dataIO.close();
		    fis.close();
		}
		catch  (Exception e) {  
		}

		String tempStr = storedString.toString();
		String[] values = tempStr.split("\n");

		Log.e(TAG, tempStr);
		
		//path
		/*
		bitmap = BitmapFactory.decodeFile(path);  

		bitmap = BitmapFactory.decodeFile("/storage/emulated/0/Output/six.jpg");
		if(bitmap != null) {
			while(bitmap.getHeight() > 2000 || bitmap.getWidth() > 2000) {  
				Log.e(TAG, "Bitmap height: " + bitmap.getHeight() + " width: " + bitmap.getWidth());
				bitmap = halfSize(bitmap);
			}  
			im.setImageBitmap(bitmap);   
		} 
		
		*/
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
