/*
 * Copyright (C) 2023 Paranoid Android
 *
 * SPDX-License-Identifier: Apache-2.0
 */

package org.lineageos.settings.doze;

import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.hardware.display.AmbientDisplayConfiguration;
import android.os.IBinder;
import android.os.UserHandle;
import android.provider.Settings;
import android.util.Log;
import android.view.Display;

import org.lineageos.settings.utils.FileUtils;

public class AodBrightnessService extends Service {

    private static final String TAG = "AodBrightnessService";
    private static final boolean DEBUG = true;

    private static final int SENSOR_TYPE_AOD = 33171029; // xiaomi.sensor.aod
    private static final float AOD_SENSOR_EVENT_BRIGHT = 4f;
    private static final float AOD_SENSOR_EVENT_DIM = 5f;
    private static final float AOD_SENSOR_EVENT_DARK = 3f;

    private static final String DOZE_BRIGHTNESS_NODE
            = "/sys/devices/virtual/mi_display/disp_feature/disp-DSI-0/doze_brightness";
    private static final String DOZE_BRIGHTNESS_ENABLE = "0";
    private static final String DOZE_BRIGHTNESS_DISABLE = "-1";

    private static final String DISP_PARAM_NODE
            = "/sys/devices/virtual/mi_display/disp_feature/disp-DSI-0/disp_param";
    private static final String DISP_PARAM_DOZE_HBM = "03 01";
    private static final String DISP_PARAM_DOZE_LBM = "03 02";

    private static final long SCREEN_OFF_WAIT_MS = 5000L;
    private static final int DOZE_HBM_BRIGHTNESS_THRESHOLD = 20;

    private SensorManager mSensorManager;
    private Sensor mAodSensor;
    private AmbientDisplayConfiguration mAmbientConfig;
    private boolean mIsDozing, mIsDozeHbm;
    private int mDisplayState = Display.STATE_ON;

    private final SensorEventListener mSensorListener = new SensorEventListener() {
        @Override
        public void onAccuracyChanged(Sensor sensor, int accuracy) { }

        @Override
        public void onSensorChanged(SensorEvent event) {
            final float value = event.values[0];
            mIsDozeHbm = (value == AOD_SENSOR_EVENT_BRIGHT);
            dlog("onSensorChanged: type=" + event.sensor.getType() + " value=" + value
                    + " mIsDozeHbm=" + mIsDozeHbm);
            if (!mHandler.hasCallbacks(mScreenOffRunnable)) {
                writeDozeParam();
            } else {
                dlog("mScreenOffRunnable pending, skip writeDozeParam");
            }
        }
    };

    private final BroadcastReceiver mScreenStateReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            dlog("onReceive: " + intent.getAction());
            switch (intent.getAction()) {
                case Intent.ACTION_SCREEN_ON:
                    if (mIsDozing) {
                        mIsDozing = false;
                        updateDozeBrightness();
                        mSensorManager.unregisterListener(mSensorListener, mAodSensor);
                    }
                    break;
                case Intent.ACTION_SCREEN_OFF:
                    if (!mAmbientConfig.alwaysOnEnabled(UserHandle.USER_CURRENT)) {
                        dlog("AOD is not enabled.");
                        mIsDozing = false;
                        break;
                    }
                    if (!mIsDozing) {
                        mIsDozing = true;
                        setInitialDozeHbmState();
                        mSensorManager.registerListener(mSensorListener,
                                mAodSensor, SensorManager.SENSOR_DELAY_NORMAL);
                    }
                    break;
                case Intent.ACTION_DISPLAY_STATE_CHANGED:
                    mDisplayState = getDisplay().getState();
                    updateDozeBrightness();
                    break;
            }
        }
    };

    private final Runnable mScreenOffRunnable = () -> {
        final int displayState = getDisplay().getState();
        dlog("displayState=" + displayState);
        if (displayState == Display.STATE_DOZE
                || displayState == Display.STATE_DOZE_SUSPEND) {
            Log.i(TAG, "We are dozing, let's do our thing.");
            writeDozeParam();
        } else {
            Log.i(TAG, "Not dozing, unregister AOD sensor.");
            mSensorManager.unregisterListener(mSensorListener, mAodSensor);
        }
    };

    public static void startService(Context context) {
         context.startServiceAsUser(new Intent(context, AodBrightnessService.class),
                UserHandle.CURRENT);
    }

    @Override
    public void onCreate() {
        super.onCreate();
        dlog("Creating service");
        mSensorManager = (SensorManager) getSystemService(Context.SENSOR_SERVICE);
        mAodSensor = mSensorManager.getDefaultSensor(SENSOR_TYPE_AOD);
        mAmbientConfig = new AmbientDisplayConfiguration(this);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        dlog("Starting service");
        IntentFilter screenStateFilter = new IntentFilter(Intent.ACTION_DISPLAY_STATE_CHANGED);
        screenStateFilter.addAction(Intent.ACTION_SCREEN_ON);
        screenStateFilter.addAction(Intent.ACTION_SCREEN_OFF);
        registerReceiver(mScreenStateReceiver, screenStateFilter);
        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        dlog("Destroying service");
        unregisterReceiver(mScreenStateReceiver);
        mSensorManager.unregisterListener(mSensorListener, mAodSensor);
        mHandler.removeCallbacksAndMessages(null);
        super.onDestroy();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    private void setInitialDozeHbmState() {
        final int brightness = Settings.System.getInt(getContentResolver(),
                Settings.System.SCREEN_BRIGHTNESS, 0);
        mIsDozeHbm = (brightness > DOZE_HBM_BRIGHTNESS_THRESHOLD);
        dlog("setInitialDozeHbmState: brightness=" + brightness + " mIsDozeHbm=" + mIsDozeHbm);
    }

    private void updateDozeBrightness() {
        dlog("updateDozeBrightness: mIsDozing=" + mIsDozing + " mDisplayState=" + mDisplayState
                + " mIsDozeHbm=" + mIsDozeHbm);
        final boolean isDozeState = mIsDozing && (mDisplayState == Display.STATE_DOZE
                || mDisplayState == Display.STATE_DOZE_SUSPEND);
        final int mode = !isDozeState ? 0 : (mIsDozeHbm ? 1 : 2);
        try {
            DfWrapper.setDisplayFeature(
                    new DfWrapper.DfParams(/*DOZE_BRIGHTNESS_STATE*/ 25, mode, 0));
        } catch (Exception e) {
            Log.e(TAG, "updateDozeBrightness failed!", e);
        }
    }

    private static void dlog(String msg) {
        if (DEBUG) Log.d(TAG, msg);
    }
}
