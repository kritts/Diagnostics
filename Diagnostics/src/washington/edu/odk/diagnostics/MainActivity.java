package washington.edu.odk.diagnostics;

import android.support.v7.app.ActionBarActivity;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;


public class MainActivity extends ActionBarActivity {
	private static final String TAG = "MainActivity";

	/** */
	private Button mGallery;

	/** */	
	private Button mCamera;  
	
	/** The action code we use in our intent, 
	 *  this way we know we're looking at the response from our own action.  */
	private static final int SELECT_PICTURE = 1;
	
	/** Used to show the users chosen image.*/
	private Bitmap bitmap = null;
	    
	
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        

        mGallery = (Button) findViewById(R.id.gallery);
        mCamera = (Button) findViewById(R.id.camera);
        
        //this.getString("CHOSE")
        mGallery.setOnClickListener(new OnClickListener() { 
			@Override
			public void onClick(View arg) { 
				Intent i = new Intent(Intent.ACTION_PICK,android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
				startActivityForResult(Intent.createChooser(i,
						"pick a photo"), SELECT_PICTURE); 
			} 
		}); 
        
        mCamera.setOnClickListener(new OnClickListener() { 
			@Override
			public void onClick(View arg) { 
				// Open up camera. 
			}  
		}); 
    }

    /**  */
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data); 
		if (resultCode == RESULT_OK) { 
			if (requestCode == SELECT_PICTURE) { 
				Uri selectedImageUri = data.getData();
				String selectedImagePath = getPath(selectedImageUri);

				bitmap = BitmapFactory.decodeFile(selectedImagePath);
				if(bitmap != null) {
					while(bitmap.getHeight() > 2000 || bitmap.getWidth() > 2000) {  
						bitmap = halfSize(bitmap);
					} 
				} 
			}
		} 
	}
	
	/**   */ 
	private Bitmap halfSize(Bitmap input) { 
		int height = input.getHeight();
		int width = input.getWidth();  
		return Bitmap.createScaledBitmap(input,  width/2, height/2, false);
	}

	/**  */
	public String getPath(Uri uri) {
		String[] projection = { MediaStore.Images.Media.DATA };
		Cursor cursor = managedQuery(uri, projection, null, null, null);
		int column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
		cursor.moveToFirst();
		return cursor.getString(column_index);
	}
    
    

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();
        if (id == R.id.action_settings) {
            return true;
        }
        return super.onOptionsItemSelected(item);
    }
}
