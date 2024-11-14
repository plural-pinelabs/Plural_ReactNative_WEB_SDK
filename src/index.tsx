import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'edge' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const EdgeModule = NativeModules.EdgeModule
  ? NativeModules.EdgeModule
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );


// Destructure the startPayment method from the Edge module
const { startPayment } = EdgeModule;

export interface paymentParams {
  options: {
    redirectUrl: string;
  };
}

export const startPayment_ = (params: paymentParams, callback: CallableFunction): void => {
  console.log("Hello flow coming here??")
  startPayment(params.options.redirectUrl, callback);
};

export default { startPayment_ };
