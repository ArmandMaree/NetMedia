package za.co.codehaven.netmediacontroller;

import android.provider.MediaStore;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.EditText;
import android.widget.Toast;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;

public class PlayMediaActivity extends AppCompatActivity {
    private EditText edtTitle;
    private EditText edtDeviceName;
    private EditText edtFullPath;
    private MediaItem mediaItem;
    private Socket socket;
    private PrintWriter out;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_play_media);
        mediaItem = (MediaItem) getIntent().getSerializableExtra("MediaItem");

        socket = MainActivity.socket;

        edtTitle = (EditText) findViewById(R.id.edtTitle);
        edtDeviceName = (EditText) findViewById(R.id.edtDeviceName);
        edtFullPath = (EditText) findViewById(R.id.edtFullPath);

        edtTitle.setText(mediaItem.getName());
        edtDeviceName.setText(mediaItem.getDeviceName());
        edtFullPath.setText(mediaItem.getFullPath());
    }


    public void onBtnPlayClick(View view) {
        try {
            out = new PrintWriter(socket.getOutputStream(), true);

            Toast.makeText(this, mediaItem.getFullPath(), Toast.LENGTH_SHORT).show();
            out.println("playmedia");
            out.println(mediaItem.getFullPath());
        } catch (IOException e) {
            e.printStackTrace();
            Toast.makeText(this, e.getMessage(), Toast.LENGTH_SHORT).show();
        }
    }

    public void onBtnStopClick(View view) {
        try {
            out = new PrintWriter(socket.getOutputStream(), true);

            out.println("stopmedia");
        } catch (IOException e) {
            e.printStackTrace();
            Toast.makeText(this, e.getMessage(), Toast.LENGTH_SHORT).show();
        }
    }
}
