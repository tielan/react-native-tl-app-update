package com.fengyu.zw.update_app;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.text.TextUtils;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.fengyu.zw.update_app.http.UpdateAppHttpUtil;
import com.fengyu.zw.update_app.http.ZWUpdateCallback;
import com.vector.update_app.UpdateAppManager;

/**
 * Created by Administrator on 2018/5/18 0018.
 */

public class UpdateManagerModule  extends ReactContextBaseJavaModule {

    public static final String REACT_CLASS = "RNReactNativeAppupdate";
    private ReactApplicationContext mReactContext;

    UpdateManagerModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.mReactContext = reactContext;

    }

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    /**
     * 初始化更新
     * @param paramsMap
     */
    @ReactMethod
    public void check(ReadableMap paramsMap) {
        String url = paramsMap.getString("url");
        if(TextUtils.isEmpty(url)){
            return;
        }
        new UpdateAppManager
                .Builder()
                .setActivity(mReactContext.getCurrentActivity())
                .setUpdateUrl(url)
                .setHttpManager(new UpdateAppHttpUtil())
                .build()
                .checkNewApp(new ZWUpdateCallback(packageName(mReactContext)));
    }

    public static int packageName(Context context) {
        PackageManager manager = context.getPackageManager();
        int  code = 0;
        try {
            PackageInfo info = manager.getPackageInfo(context.getPackageName(), 0);
            code = info.versionCode;
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        return code;
    }
}
