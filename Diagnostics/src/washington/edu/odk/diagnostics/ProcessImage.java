package washington.edu.odk.diagnostics;

import org.opencv.android.BaseLoaderCallback;
import org.opencv.android.LoaderCallbackInterface;
import org.opencv.android.OpenCVLoader; 

import android.support.v7.app.ActionBarActivity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory; 
import android.os.Bundle;
import android.os.Environment;
import android.util.Log; 
import android.widget.ImageView;

// This is the 
public class ProcessImage extends ActionBarActivity {
	private static final String TAG = "ProcessImage";

	/** Used to show the users chosen image.*/
	private Bitmap bitmap = null;
	
	private ImageView im;
	
	private boolean mOpenCVInitiated = false;
	
	private String path;

	private int resultCode;
	
	public native String findCirclesNative(String imagePath);
	 
	
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
			path = Environment.getExternalStorageDirectory() + "/Diagnostics_Images" + path;
			Log.e(TAG, path);
		}
		Log.e(TAG, path);
	}
		
	
	private void setImage() {  
		String output_path = findCirclesNative(path); 
		bitmap = BitmapFactory.decodeFile(path);  

		bitmap = BitmapFactory.decodeFile(output_path);
		if(bitmap != null) {
			while(bitmap.getHeight() > 2000 || bitmap.getWidth() > 2000) {  
				Log.e(TAG, "Bitmap height: " + bitmap.getHeight() + " width: " + bitmap.getWidth());
				bitmap = halfSize(bitmap);
			}  
			im.setImageBitmap(bitmap);   
		} 
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
