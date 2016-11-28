package za.co.codehaven.netmediacontroller;

import android.app.Activity;
import android.app.ListActivity;
import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.Toast;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Objects;

public class ListMediaActivity extends AppCompatActivity {
    private  ArrayList<MediaItem> mediaItems = new ArrayList<>();
    private ArrayAdapter<MediaItem> mediaItemsAdapter;
    private ListView lstvwMediaItems;
    private EditText edtMediaSearch;
    private Socket socket;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_list_media);

        socket = MainActivity.socket;

        lstvwMediaItems = (ListView) findViewById(R.id.lstvwMediaItems);
        edtMediaSearch = (EditText) findViewById(R.id.edtMediaSearch);

        mediaItemsAdapter = new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, mediaItems);
        lstvwMediaItems.setAdapter(mediaItemsAdapter);
        addItems();

        edtMediaSearch.addTextChangedListener(new TextWatcher() {
            @Override
            public void onTextChanged(CharSequence cs, int arg1, int arg2, int arg3) {
                ListMediaActivity.this.mediaItemsAdapter.getFilter().filter(cs);
            }

            @Override
            public void beforeTextChanged(CharSequence arg0, int arg1, int arg2, int arg3) {
                // TODO Auto-generated method stub
            }

            @Override
            public void afterTextChanged(Editable arg0) {
                // TODO Auto-generated method stub
            }
        });

        lstvwMediaItems.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                MediaItem item = mediaItemsAdapter.getItem(position);
                Intent intent = new Intent(view.getContext(), MediaDetailsActivity.class);
                intent.putExtra("MediaItem", item);
                startActivityForResult(intent, 0);
            }
        });
    }

    public void addItems() {
        try {
            PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
            BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            out.println("listmedia");
            String reply;
            while ((reply = in.readLine()) != null) {
                if (!reply.equals("DONE")) {
                    MediaItem mi = new MediaItem();
                    String path = reply.substring(reply.indexOf('@') + 1);
                    mi.setFullPath(path);
                    mi.setDeviceName(reply.substring(0, reply.indexOf('@')));
                    mi.setFileName(path.substring(path.lastIndexOf('/') + 1));
                    mediaItems.add(mi);
                }
                else
                    break;
            }

            mediaItemsAdapter.sort(new Comparator<MediaItem>() {
                @Override
                public int compare(MediaItem lhs, MediaItem rhs) {
                    return lhs.compareTo(rhs);
                }
            });

            mediaItemsAdapter.notifyDataSetChanged();
        } catch (IOException e) {
            e.printStackTrace();
            Toast.makeText(this, e.getMessage(), Toast.LENGTH_SHORT).show();
        }
    }
}
