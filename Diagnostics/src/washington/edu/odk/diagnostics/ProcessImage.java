package washington.edu.odk.diagnostics;

import org.opencv.android.BaseLoaderCallback;
import org.opencv.android.LoaderCallbackInterface;
import org.opencv.android.OpenCVLoader;

import android.support.v7.app.ActionBarActivity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Button;
import android.widget.ImageView;

// This is the 
public class ProcessImage extends ActionBarActivity {
	private static final String TAG = "ProcessImage";

	/** Used to show the users chosen image.*/
	private Bitmap bitmap = null;
	private ImageView im;
	public native String findCirclesNative(String imagePath);
	private boolean mOpenCVInitiated = false;
	private String path;
	
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_process_image);
		OpenCVLoader.initAsync(OpenCVLoader.OPENCV_VERSION_2_4_3, this, mLoaderCallback);
		im = (ImageView) findViewById(R.id.image);
        
		
		Intent intent = getIntent();
		Bundle extras = intent.getExtras();  
		path  = extras.getString("path");  //TODO: Make sure absolute path;
		Log.e(TAG, path);
		Log.e(TAG, "!!!!!!!!!!!!!!!" + " " +  mOpenCVInitiated);
 
	}
		
	
	private void setImage() { 
		Log.e(TAG, path);
		Log.e(TAG, "!!!!!!!!!!!!!!!" + " " +  mOpenCVInitiated);
		
		 
		String output_path = findCirclesNative(path);
		Log.e(TAG, output_path);
		 
		Log.e(TAG, output_path);
		
		bitmap = BitmapFactory.decodeFile(path); 
		
		 

		bitmap = BitmapFactory.decodeFile(output_path);
		if(bitmap != null) {
			while(bitmap.getHeight() > 2000 || bitmap.getWidth() > 2000) {  
				bitmap = halfSize(bitmap);
			} 
			Log.e(TAG, "Bitmap height: " + bitmap.getHeight() + " width: " + bitmap.getWidth());
			im.setImageBitmap(bitmap);   
		} 
	}
		
	 
 
    
    @Override
    public void onResume() {
        super.onResume();
        
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
