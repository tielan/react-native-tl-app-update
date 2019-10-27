import {
    NativeModules,
} from 'react-native';
const UpdateManagerModule = NativeModules.RNReactNativeAppupdate;
export default class UpdateManager {
    //自动检测更新
    static check({ url }) {
        if (url) {
            UpdateManagerModule.check({ url });
        }
    }
    //手动检测更新
    static manual({ url }, callback) {
        if (url) {
            UpdateManagerModule.manual({ url }, callback);
        }
    }
}