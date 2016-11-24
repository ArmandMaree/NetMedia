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

public class ListDevicesActivity extends AppCompatActivity {
    ArrayList<String> devices = new ArrayList<>();
    ArrayAdapter<String> devicesAdapter;
    ListView lstvwDevices;
    EditText edtDeviceSearch;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_list_devices);
        lstvwDevices = (ListView) findViewById(R.id.lstvwDevices);
        edtDeviceSearch = (EditText) findViewById(R.id.edtDeviceSearch);

        devicesAdapter = new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, devices);
        lstvwDevices.setAdapter(devicesAdapter);
        addItems();

        edtDeviceSearch.addTextChangedListener(new TextWatcher() {
            @Override
            public void onTextChanged(CharSequence cs, int arg1, int arg2, int arg3) {
                ListDevicesActivity.this.devicesAdapter.getFilter().filter(cs);
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
    }

    public void addItems() {
        devices.add("armandmaree-desktop");
        devices.add("letitia-laptop");

        devicesAdapter.notifyDataSetChanged();
    }
}
