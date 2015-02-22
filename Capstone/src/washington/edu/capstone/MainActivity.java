package washington.edu.capstone;

import java.io.File; 
import android.net.Uri;
import android.util.Log;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.content.Intent;
import android.os.Environment;
import android.database.Cursor; 
import android.provider.MediaStore; 
import android.view.View.OnClickListener;
import android.support.v7.app.ActionBarActivity;

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
	
	/** The action code we use in our intent, 
	 *  this way we know we're looking at the response from our own action.  */
	private static final int TAKE_PICTURE = 2;
	
	/** Path of the image currently being processed. */
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
				Intent i = new Intent(Intent.ACTION_PICK,android
						.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
				
				startActivityForResult(
						Intent.createChooser(i,
						MainActivity.this.getString(R.string.select)), 
						SELECT_PICTURE); 
			} 
		}); 
        createFolderSetup();
		 
        mCamera.setOnClickListener(new OnClickListener() { 
			@Override
			public void onClick(View arg) {  
				Intent intent = new Intent(android.provider.
										   MediaStore.ACTION_IMAGE_CAPTURE);
				
                intent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
                startActivityForResult(intent, TAKE_PICTURE);
			}  
		}); 
    }
    
    private void createFolderSetup() {
		File diagnostics_imgs_folder = new File(
				Environment.getExternalStorageDirectory(), "Diagnostics_Images");
		diagnostics_imgs_folder.mkdirs();  
		
    	File orig_imgs_folder = new File(
    			Environment.getExternalStorageDirectory() + "/Diagnostics_Images",
    			"Original_Images");
		orig_imgs_folder.mkdirs(); 
         
		File proc_imgs_folder = new File(
				Environment.getExternalStorageDirectory() + "/Diagnostics_Images",
				"Processed_Images"); 
		proc_imgs_folder.mkdirs(); 
		
		File proc_data_folder = new File(
				Environment.getExternalStorageDirectory() + "/Diagnostics_Images",
				"Processed_Data");
		proc_data_folder.mkdirs();   
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
					 // shouldn't be null
					selectedImagePath = Environment.getExternalStorageDirectory()
							+ "/Diagnostics_Images/Original_Images/" + mImagePath;
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

