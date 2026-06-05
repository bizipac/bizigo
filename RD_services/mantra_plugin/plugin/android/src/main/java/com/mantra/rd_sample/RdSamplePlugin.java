package com.mantra.rd_sample;

import android.app.Activity;
import android.content.Intent;
import android.util.Log;

import androidx.annotation.NonNull;

import java.util.HashMap;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
// import io.flutter.plugin.common.PluginRegistry;

/**
 * RdSamplePlugin
 */
public class RdSamplePlugin implements FlutterPlugin, MethodCallHandler,
ActivityAware, io.flutter.plugin.common.PluginRegistry.ActivityResultListener {

	private static final String channelName = "rd_sample";

	/// The MethodChannel that will the communication between Flutter and native Android
	///
	/// This local reference serves to register the plugin with the Flutter Engine and unregister it
	/// when the Flutter Engine is detached from the Activity
	private MethodChannel channel;
	private static Activity activity;
	private Result pendingResult;


	// public static void registerWith(PluginRegistry.Registrar registrar) {
	// 	activity = registrar.activity();
	// 	final MethodChannel channel = new MethodChannel(registrar.messenger(), channelName);
	// 	channel.setMethodCallHandler(new RdSamplePlugin());
	// }

	@Override
	public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
		channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), channelName);
		channel.setMethodCallHandler(this);
	}

	@Override
	public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
		if (call.method.equals("getPlatformVersion")) {
			result.success("Android " + android.os.Build.VERSION.RELEASE);
		} else if (call.method.equals("finger_device_info")) {

			try {
				this.pendingResult = result;

				Intent intent = new Intent();
				intent.setAction("in.gov.uidai.rdservice.fp.INFO");
				activity.startActivityForResult(intent, 1);
			} catch (Exception exception) {
				Log.e("Tag", "exception : : " + exception);
			}


		} else if (call.method.equals("capture")) {
			this.pendingResult = result;
			String PIDData = call.argument("text");
			Log.e("Tag", "text : " + PIDData);
//			String PIDData="<PidOptions ver=\"1.0\">\n" +
//					"       <CustOpts>\n" +
//					"          <Param/>\n" +
//					"       </CustOpts>\n" +
//					"       <Opts env=\"S\" fCount=\"1\" fType=\"0\" format=\"0\" iCount=\"0\" iType=\"0\" pCount=\"0\" pTimeout=\"20000\" pType=\"0\" pgCount=\"2\" pidVer=\"2.0\" posh=\"UNKNOWN\" timeout=\"10000\"/>\n" +
//					"    </PidOptions>";
			Intent intent = new Intent();
			intent.setAction("in.gov.uidai.rdservice.fp.CAPTURE");
			intent.putExtra("PID_OPTIONS", PIDData);
			activity.startActivityForResult(intent, 2);
		} else if (call.method.equals("iris_device_info")) {
			try {
				this.pendingResult = result;

				Intent intent = new Intent();
				intent.setAction("in.gov.uidai.rdservice.iris.INFO");
				activity.startActivityForResult(intent, 3);
			} catch (Exception exception) {
				Log.e("Tag", "exception : : " + exception);
			}

		} else if (call.method.equals("iriscapture")) {
			this.pendingResult = result;
			String PIDData = call.argument("text");
			Log.e("Tag", "text : " + PIDData);
			Intent intent = new Intent();
			intent.setAction("in.gov.uidai.rdservice.iris.CAPTURE");
			intent.putExtra("PID_OPTIONS", PIDData);
			activity.startActivityForResult(intent, 4);
		} else {
			result.notImplemented();
		}
	}

	@Override
	public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
		channel.setMethodCallHandler(null);
	}

	@Override
	public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
		activity = binding.getActivity();
		binding.addActivityResultListener(this);
	}

	@Override
	public void onDetachedFromActivityForConfigChanges() {
	}

	@Override
	public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
	}

	@Override
	public void onDetachedFromActivity() {
		activity = null;
	}

	@Override
	public boolean onActivityResult(int requestCode, int resultCode, Intent data) {

		switch (requestCode) {
			case 1:
				if (resultCode == Activity.RESULT_OK) {
					try {
						if (data != null) {
							HashMap<String, String> device_info = new HashMap<>();
							String result = data.getStringExtra("DEVICE_INFO");
							if (result != null) {
								device_info.put("DEVICE_INFO", result);
							}
//                            Log.e("Tag","DEVICE_INFO : "+result );
							String rdService = data.getStringExtra("RD_SERVICE_INFO");
							if (rdService != null) {
								device_info.put("RD_SERVICE_INFO", rdService);
							}
//                            Log.e("Tag","rdService info : "+rdService );
//                            Log.e("Tag","device_info : "+device_info);
							pendingResult.success(device_info);
						}
					} catch (Exception e) {
						Log.e("Error", "Error while deserialze device info", e);
					}
				} else {
					pendingResult.error("-11", "", "");
				}
				break;
			case 2:
				if (resultCode == Activity.RESULT_OK) {
					try {
						if (data != null) {
							String result = data.getStringExtra("PID_DATA");
							Log.e("Tag", "PID_DATA : " + result);
							if (result != null) {
//								pidData = serializer.read(PidData.class, result);
								// setText(result);
//								setText(result, "PidData");
//								Config.DataLog(pidData._DeviceInfo.mc, "MC", ".cer");
								pendingResult.success(result);
							}

						} else {
							pendingResult.error("-11", "Devices info not get", "");
						}
					} catch (Exception e) {
						Log.e("Error", "Error while deserialze pid data", e);
					}
				}
				break;
			case 3:
				if (resultCode == Activity.RESULT_OK) {
					try {
						if (data != null) {
							HashMap<String, String> device_info = new HashMap<>();
							String result = data.getStringExtra("DEVICE_INFO");
							if (result != null) {
								device_info.put("DEVICE_INFO", result);
							}
//                            Log.e("Tag","DEVICE_INFO : "+result );
							String rdService = data.getStringExtra("RD_SERVICE_INFO");
							if (rdService != null) {
								device_info.put("RD_SERVICE_INFO", rdService);
							}
//                            Log.e("Tag","rdService info : "+rdService );
//                            Log.e("Tag","device_info : "+device_info);
							pendingResult.success(device_info);
						}
					} catch (Exception e) {
						Log.e("Error", "Error while deserialze device info", e);
					}
				} else {
					pendingResult.error("-11", "Devices info not get", "");
				}
				break;
			case 4:
				if (resultCode == Activity.RESULT_OK) {
					try {
						if (data != null) {
							String result = data.getStringExtra("PID_DATA");
							Log.e("Tag", "PID_DATA : " + result);
							if (result != null) {
							}
							pendingResult.success(result);
						}
					} catch (Exception e) {
						Log.e("Error", "Error while deserialze pid data", e);
					}
				}
				break;

		}
		return false;
	}
}
