package com.fengyu.zw.update_app.http;


import com.vector.update_app.UpdateAppBean;
import com.vector.update_app.UpdateAppManager;
import com.vector.update_app.UpdateCallback;

import org.json.JSONObject;

public class ZWUpdateCallback extends UpdateCallback {

    private int versionCode;

    public ZWUpdateCallback(int versionCode) {
        this.versionCode = versionCode;
    }

    /**
     * 解析json,自定义协议
     *
     * @param json 服务器返回的json
     * @return UpdateAppBean
     */
    protected UpdateAppBean parseJson(String json) {
        UpdateAppBean updateAppBean = new UpdateAppBean();
        try {
            try {
                JSONObject jsonObject = new JSONObject(json);
                int version_num = jsonObject.optInt("version_num");
                String update = "";
                if (versionCode < version_num) {
                    update = "Yes";
                }
                updateAppBean.setUpdate(update)
                        .setOriginRes(json)
                        .setNewVersion(jsonObject.optString("new_version"))
                        .setApkFileUrl( jsonObject.optString("apk_file_url"))
                        .setTargetSize(jsonObject.optString("target_size"))
                        .setUpdateLog(jsonObject.optString("update_log"))
                        .setConstraint(jsonObject.optBoolean("constraint"))
                        .setNewMd5(jsonObject.optString("new_md5"));
            } catch (Exception e) {
                e.printStackTrace();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return updateAppBean;
    }

    /**
     * 有新版本
     *
     * @param updateApp        新版本信息
     * @param updateAppManager app更新管理器
     */
    protected void hasNewApp(UpdateAppBean updateApp, UpdateAppManager updateAppManager) {
        updateAppManager.showDialogFragment();
    }

    /**
     * 网路请求之后
     */
    protected void onAfter() {
    }


    /**
     * 没有新版本
     *
     * @param error HttpManager实现类请求出错返回的错误消息，交给使用者自己返回，有可能不同的应用错误内容需要提示给客户
     */
    protected void noNewApp(String error) {
    }

    /**
     * 网络请求之前
     */
    protected void onBefore() {
    }

}