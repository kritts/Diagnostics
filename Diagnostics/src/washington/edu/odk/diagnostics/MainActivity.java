package washington.edu.odk.diagnostics;

import java.io.File;
import java.util.Calendar;  

import android.support.v7.app.ActionBarActivity;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore; 
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;

/** 
 * This is the home page of the MRSA Diagnostics app. 
 * It gives the user two options to select a photo to process: 
 * take a new photo or choose an old photo.
 * @author Krittika D'Silva (krittika.dsilva@gmail.com)
 */
public class MainActivity extends ActionBarActivity {
	private static final String TAG = "MainActivity";

	/** Opens the camera's gallery so that the user 
	 * can select an image of a test to process. */
	private Button mGallery;

	/** Opens the camera so that the user can take 
	 * an image of a test to analyze*/	
	private Button mCamera;  
	
	/** The action code we use in our intent, 
	 *  this way we know we're looking at the response from our own action.  */
	private static final int SELECT_PICTURE = 1;
	
	/** */
	private static final int TAKE_PICTURE = 2;
	
	private String mImagePath = null;
	    
	
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
         
        mGallery = (Button) findViewById(R.id.gallery);
        mCamera = (Button) findViewById(R.id.camera);
         
        mGallery.setOnClickListener(new OnClickListener() { 
			@Override
			public void onClick(View arg) { 
				Intent i = new Intent(Intent.ACTION_PICK,android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
				startActivityForResult(Intent.createChooser(i,
						MainActivity.this.getString(R.string.select)), SELECT_PICTURE); 
			} 
		}); 
        
        mCamera.setOnClickListener(new OnClickListener() { 
			@Override
			public void onClick(View arg) { 
				Calendar c = Calendar.getInstance();
				
				// Name of image file is the data and then time the image was taken. 
				String date = c.get(Calendar.YEAR) + "_"+ c.get(Calendar.MONTH)
						+ "_" + c.get(Calendar.DAY_OF_MONTH);
				String time = c.get(Calendar.HOUR_OF_DAY) + "_" 
						+ c.get(Calendar.MINUTE) + "_" + c.get(Calendar.SECOND);

				mImagePath = "/" + date + "__" + time;
				 
				mImagePath += ".jpg"; 
				 
				 
			    Uri imageUri = Uri.fromFile(new File(mImagePath));
				Intent intent = new Intent(android.provider.MediaStore.ACTION_IMAGE_CAPTURE);
                //intent.putExtra(MediaStore.EXTRA_OUTPUT, imageUri);
				
				File imagesFolder = new File(Environment.getExternalStorageDirectory(), "Diagnostics_Images");
				imagesFolder.mkdirs(); 
				File photo = new File(imagesFolder, mImagePath + ".jpg");
				Uri uriSavedImage = Uri.fromFile(photo);
				intent.putExtra(MediaStore.EXTRA_OUTPUT, uriSavedImage);  
                intent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
                startActivityForResult(intent, TAKE_PICTURE);
			}  
		}); 
    }

    /** Called after an image has been chosen. */
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data); 
		if (resultCode == RESULT_OK) { 
			if (requestCode == SELECT_PICTURE || requestCode == TAKE_PICTURE) { 
				Log.e(TAG, "Image selected");
				
				String selectedImagePath;  
				if(data != null) { 
					Uri selectedImageUri = data.getData();
					selectedImagePath = getPath(selectedImageUri); 
				} else {
					selectedImagePath = mImagePath; // shouldn't be null
				}
				Intent intent = new Intent(MainActivity.this, ProcessImage.class);
				intent.putExtra("resultCode", requestCode); 
				intent.putExtra("path", selectedImagePath); 
				startActivity(intent); 
			}  
		} 
	}


	/** Given a uri, returns the absolute path as a string. */
	public String getPath(Uri uri) {
		String[] projection = { MediaStore.Images.Media.DATA };
		Cursor cursor = managedQuery(uri, projection, null, null, null);
		int column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
		cursor.moveToFirst();
		return cursor.getString(column_index);
	} 
}
