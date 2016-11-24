package za.co.codehaven.netmediacontroller;

import java.io.Serializable;

/**
 * Created by armandmaree on 2016/11/23.
 */

public class MediaItem implements Serializable, Comparable<MediaItem> {
    private String fileName = "UNKNOWN";
    private String title = "UNKNOWN";
    private String fullPath = "UNKNOWN";
    private String deviceName = "UNKNOWN";

    public MediaItem() {

    }

    public MediaItem(String title) {
        this.title = title;
    }

    public String getName() {
        if (title.equals("UNKNOWN"))
            return fileName;
        else
            return title;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getFullPath() {
        return fullPath;
    }

    public void setFullPath(String fullPath) {
        this.fullPath = fullPath;
    }

    public String getDeviceName() {
        return deviceName;
    }

    public void setDeviceName(String deviceName) {
        this.deviceName = deviceName;
    }

    @Override
    public String toString() {
        return getName();
    }

//    @Override
    public int compareTo(MediaItem mediaItem) {
        return getName().compareTo(mediaItem.getName());
    }
}
