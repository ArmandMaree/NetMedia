package za.co.codehaven.netmediacontroller;

import android.content.Intent;
import android.os.StrictMode;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;

import java.io.IOException;
import java.net.InetAddress;
import java.net.Socket;
import java.net.UnknownHostException;

public class MainActivity extends AppCompatActivity {
    Button btnListMedia;
    Button btnListDevices;
    static String SERVER_IP = "10.0.2.2";
    static int SERVER_PORT = 5001;
    static Socket socket = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);

        try {
            InetAddress serverAddr = InetAddress.getByName(SERVER_IP);
            socket = new Socket(serverAddr, SERVER_PORT);
        } catch (IOException e1) {
            e1.printStackTrace();
            Toast.makeText(this, "ERROR: Could not connect to server.", Toast.LENGTH_SHORT).show();
        }

        btnListMedia = (Button) findViewById(R.id.btnListMedia);
        btnListDevices = (Button) findViewById(R.id.btnListDevices);
    }

    public void onBtnListMediaClick(View view) {
        Intent intent = new Intent(view.getContext(), ListMediaActivity.class);
        startActivityForResult(intent, 0);
    }

    public void onBtnListDevicesClick(View view) {
        Intent intent = new Intent(view.getContext(), ListDevicesActivity.class);
        startActivityForResult(intent, 0);
    }

    public void onBtnPlayMediaClick(View view) {
        Intent intent = new Intent(view.getContext(), ListServerMediaActivity.class);
        startActivityForResult(intent, 0);
    }
}
