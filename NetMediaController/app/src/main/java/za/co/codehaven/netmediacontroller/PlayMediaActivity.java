package za.co.codehaven.netmediacontroller;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.widget.EditText;

public class PlayMediaActivity extends AppCompatActivity {
    EditText edtTitle;
    EditText edtDeviceName;
    EditText edtFullPath;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_play_media);
        MediaItem item = (MediaItem) getIntent().getSerializableExtra("MediaItem");

        edtTitle = (EditText) findViewById(R.id.edtTitle);
        edtDeviceName = (EditText) findViewById(R.id.edtDeviceName);
        edtFullPath = (EditText) findViewById(R.id.edtFullPath);

        edtTitle.setText(item.getName());
        edtDeviceName.setText(item.getDeviceName());
        edtFullPath.setText(item.getFullPath());
    }
}
