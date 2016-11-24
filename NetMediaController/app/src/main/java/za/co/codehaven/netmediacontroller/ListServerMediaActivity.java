package za.co.codehaven.netmediacontroller;

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

import java.util.ArrayList;

public class ListServerMediaActivity extends AppCompatActivity {
    ArrayList<MediaItem> mediaItems = new ArrayList<>();
    ArrayAdapter<MediaItem> mediaItemsAdapter;
    ListView lstvwMediaItems;
    EditText edtMediaSearch;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_list_server_media);

        lstvwMediaItems = (ListView) findViewById(R.id.lstvwMediaItems);
        edtMediaSearch = (EditText) findViewById(R.id.edtMediaSearch);

        mediaItemsAdapter = new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, mediaItems);
        lstvwMediaItems.setAdapter(mediaItemsAdapter);
        addItems();

        edtMediaSearch.addTextChangedListener(new TextWatcher() {
            @Override
            public void onTextChanged(CharSequence cs, int arg1, int arg2, int arg3) {
                ListServerMediaActivity.this.mediaItemsAdapter.getFilter().filter(cs);
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
                Intent intent = new Intent(view.getContext(), PlayMediaActivity.class);
                intent.putExtra("MediaItem", item);
                startActivityForResult(intent, 0);
            }
        });
    }

    public void addItems() {
        mediaItems.add(new MediaItem("Avengers"));
        mediaItems.add(new MediaItem("Avengers: Age of Ultron"));
        mediaItems.add(new MediaItem("Casino Royal"));
        mediaItems.add(new MediaItem("Evil Dead"));
        mediaItems.add(new MediaItem("Pineapple Express"));
        mediaItems.add(new MediaItem("Tenacious D"));

        for (MediaItem mi : mediaItems) {
            mi.setDeviceName("armandmaree-desktop");
            mi.setFullPath("/home/armandmaree/Videos/NetMedia/");
        }

        mediaItemsAdapter.notifyDataSetChanged();
    }

}
