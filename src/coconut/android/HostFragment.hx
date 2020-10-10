package coconut.android;

import androidx.fragment.app.Fragment;
import android.view.LayoutInflater;
import android.view.ViewGroup;
import android.view.ViewGroup.ViewGroup_LayoutParams;
import android.os.Bundle;
import android.widget.LinearLayout;
import coconut.diffing.*;
import coconut.ui.*;
import coconut.android.Isolated;

import io.socket.client.IO;
import io.socket.client.Socket;
import io.socket.emitter.Emitter;
import io.socket.emitter.Emitter.Emitter_Listener;

import haxe.io.Bytes;
import java.io.File;
import java.io.FileOutputStream;
import haxe.io.Path;
import dalvik.system.DexClassLoader;

class HostFragment extends Fragment {
    private var mSocket:Socket;
    @:overload public function new(){
        super();
        try {
            mSocket = IO.socket("http://10.0.2.2:3333/"); // host computer IP (only works in emulator)
            
        } catch (e:haxe.Exception) {
            throw e;
        }
    }
    @:overload override function onCreateView(inflater:LayoutInflater, container:ViewGroup, savedInstanceState:Bundle) {
        mSocket.on("app:reload", new AppReloadEmitter(onAppReload));
        mSocket.connect();
        trace("[APP_RELOAD_LISTENER]: CONNECTED");
        var appView = new LinearLayout(container.getContext());
        appView.setLayoutParams(new ViewGroup_LayoutParams(ViewGroup_LayoutParams.MATCH_PARENT, ViewGroup_LayoutParams.MATCH_PARENT));
        return appView;
    }

    function onAppReload(args:java.NativeArray<Dynamic>){
        trace("[APP_RELOAD]", args);
        //Load dex file from network, and get app view
        // packet is an hex encoded dex file
        var packet:String = cast args[0];
        if (packet == null){
            var dexBytes:Bytes = Bytes.ofHex(packet);
            var basePath = getContext().getFilesDir();
            var dexFile = new File(Path.join([basePath.getPath(), "coco.dex"]));
    
            try {
                if (!dexFile.exists()) {
                    dexFile.createNewFile();
                }
                var fos = new FileOutputStream(dexFile);
                fos.write(dexBytes.getData());
                fos.close();

                var dexPath = dexFile.getPath();
                var optimizedDirectory = dexFile.getParent();
                var parent = cast(this, java.lang.Object).getClass().getClassLoader();

                var classLoader = new DexClassLoader(dexPath, optimizedDirectory, null, parent);

                var appClazz = classLoader.loadClass('${getContext().getPackageName()}.AppLauncher');
                var mount = appClazz.getDeclaredMethod("mount", java.NativeArray.make(cast(getView(), java.lang.Object).getClass()));
                trace("[APP_UNMOUNT]");
                cast(getView, ViewGroup).removeAllViews();
                var mounted:Bool = cast mount.invoke(appClazz, java.NativeArray.make(getView()));
                trace('[APP_MOUNTED]: $mounted');
            } catch (e:Dynamic) {
                throw e;
            }
        }
    }


    @:overload override public function onDestroyView() {
        super.onDestroyView();
        mSocket.disconnect();
    }
}


private class AppReloadEmitter implements Emitter.Emitter_Listener {
    var callback:java.NativeArray<Dynamic>->Void;
    public function new(callback:java.NativeArray<Dynamic>->Void){
        this.callback = callback;
    }

    public function call(args:java.NativeArray<Dynamic>){
        try{
            callback(args);
        }catch(e:Dynamic){
            throw e;
        }
        
    }
}