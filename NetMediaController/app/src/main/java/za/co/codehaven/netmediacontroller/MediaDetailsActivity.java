package za.co.codehaven.netmediacontroller;

import android.os.Handler;
import android.os.Message;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.widget.EditText;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.Comparator;
import java.util.Timer;
import java.util.TimerTask;

public class MediaDetailsActivity extends AppCompatActivity {
    private EditText edtTitle;
    private EditText edtDeviceName;
    private EditText edtFullPath;
    private TextView tvProgress;
    private ProgressBar pbProgress;

    private Socket socket;
    private PrintWriter out;
    private BufferedReader in;
    private MediaItem item;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_media_details);

        tvProgress = (TextView) findViewById(R.id.tvDownloadProgress);
        pbProgress = (ProgressBar) findViewById(R.id.pbDownloadProgress);

        socket = MainActivity.socket;
        item = (MediaItem) getIntent().getSerializableExtra("MediaItem");

        edtTitle = (EditText) findViewById(R.id.edtTitle);
        edtDeviceName = (EditText) findViewById(R.id.edtDeviceName);
        edtFullPath = (EditText) findViewById(R.id.edtFullPath);

        edtTitle.setText(item.getName());
        edtDeviceName.setText(item.getDeviceName());
        edtFullPath.setText(item.getFullPath());
    }

    public void onBtnDownloadMediaClick(View view) {
        try {
            out = new PrintWriter(socket.getOutputStream(), true);
            in = new BufferedReader(new InputStreamReader(socket.getInputStream()));

            out.println("getMedia");
            out.println(item.getDeviceName());
            out.println(item.getFullPath());

            tvProgress.setVisibility(View.VISIBLE);
            pbProgress.setVisibility(View.VISIBLE);

            new Thread() {
                @Override
                public void run() {
                    String reply;

                    try {
                        while ((reply = in.readLine()) != null) {
                            if (!reply.equals("DONE")) {
                                final String finalReply = reply;
                                runOnUiThread(new Runnable() {
                                    @Override
                                    public void run() {
                                        tvProgress.setText(finalReply);
                                    }
                                });
                            } else
                                break;
                        }
                    } catch (IOException e) {
                        e.printStackTrace();
                    }

                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            pbProgress.setVisibility(View.INVISIBLE);
                        }
                    });
                }
            }.start();
        } catch (IOException e) {
            e.printStackTrace();
            Toast.makeText(this, e.getMessage(), Toast.LENGTH_SHORT).show();
        }
    }
}
