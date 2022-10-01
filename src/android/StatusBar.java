/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
 */
package org.apache.cordova.statusbar;

import android.app.Activity;
import android.graphics.Color;
import android.os.Build;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsControllerCompat;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.LOG;
import org.apache.cordova.PluginResult;
import org.json.JSONException;

public class StatusBar extends CordovaPlugin {
    private static final String TAG = "StatusBar";

    private static final String ACTION_HIDE = "hide";
    private static final String ACTION_SHOW = "show";
    private static final String ACTION_READY = "_ready";
    private static final String ACTION_BACKGROUND_COLOR_BY_HEX_STRING = "backgroundColorByHexString";
    private static final String ACTION_OVERLAYS_WEB_VIEW = "overlaysWebView";
    private static final String ACTION_STYLE_DEFAULT = "styleDefault";
    private static final String ACTION_STYLE_LIGHT_CONTENT = "styleLightContent";

    private static final String STYLE_DEFAULT = "default";
    private static final String STYLE_LIGHT_CONTENT = "lightcontent";

    /**
     * Sets the context of the Command. This can then be used to do things like
     * get file paths associated with the Activity.
     *
     * @param cordova The context of the main Activity.
     * @param webView The CordovaWebView Cordova is running in.
     */
    @Override
    public void initialize(final CordovaInterface cordova, CordovaWebView webView) {
        LOG.v(TAG, "StatusBar: initialization");
        super.initialize(cordova, webView);

        this.cordova.getActivity().runOnUiThread(() -> {
            // Clear flag FLAG_FORCE_NOT_FULLSCREEN which is set initially
            // by the Cordova.
            Window window = cordova.getActivity().getWindow();
            window.clearFlags(WindowManager.LayoutParams.FLAG_FORCE_NOT_FULLSCREEN);

            // Read 'StatusBarOverlaysWebView' from config.xml, default is true.
            setStatusBarTransparent(preferences.getBoolean("StatusBarOverlaysWebView", true));

            // Read 'StatusBarBackgroundColor' from config.xml, default is #000000.
            setStatusBarBackgroundColor(preferences.getString("StatusBarBackgroundColor", "#000000"));

            // Read 'StatusBarStyle' from config.xml, default is 'lightcontent'.
            setStatusBarStyle(
                preferences.getString("StatusBarStyle", STYLE_LIGHT_CONTENT).toLowerCase()
            );
        });
    }

    /**
     * Executes the request and returns PluginResult.
     *
     * @param action            The action to execute.
     * @param args              JSONArry of arguments for the plugin.
     * @param callbackContext   The callback id used when calling back into JavaScript.
     * @return                  True if the action was valid, false otherwise.
     */
    @Override
    public boolean execute(final String action, final CordovaArgs args, final CallbackContext callbackContext) {
        LOG.v(TAG, "Executing action: " + action);
        final Activity activity = this.cordova.getActivity();
        final Window window = activity.getWindow();

        if (ACTION_READY.equals(action)) {
            boolean statusBarVisible = (window.getAttributes().flags & WindowManager.LayoutParams.FLAG_FULLSCREEN) == 0;
            callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, statusBarVisible));
            return true;
        }

        if (ACTION_SHOW.equals(action)) {
            this.cordova.getActivity().runOnUiThread(() -> {
                int uiOptions = window.getDecorView().getSystemUiVisibility();
                uiOptions &= ~View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN;
                uiOptions &= ~View.SYSTEM_UI_FLAG_FULLSCREEN;

                window.getDecorView().setSystemUiVisibility(uiOptions);

                // CB-11197 We still need to update LayoutParams to force status bar
                // to be hidden when entering e.g. text fields
                window.clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
            });
            return true;
        }

        if (ACTION_HIDE.equals(action)) {
            this.cordova.getActivity().runOnUiThread(() -> {
                int uiOptions = window.getDecorView().getSystemUiVisibility()
                    | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_FULLSCREEN;

                window.getDecorView().setSystemUiVisibility(uiOptions);

                // CB-11197 We still need to update LayoutParams to force status bar
                // to be hidden when entering e.g. text fields
                window.addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
            });
            return true;
        }

        if (ACTION_BACKGROUND_COLOR_BY_HEX_STRING.equals(action)) {
            this.cordova.getActivity().runOnUiThread(() -> {
                try {
                    setStatusBarBackgroundColor(args.getString(0));
                } catch (JSONException ignore) {
                    LOG.e(TAG, "Invalid hexString argument, use f.i. '#777777'");
                }
            });
            return true;
        }

        if (ACTION_OVERLAYS_WEB_VIEW.equals(action)) {
            this.cordova.getActivity().runOnUiThread(() -> {
                try {
                    setStatusBarTransparent(args.getBoolean(0));
                } catch (JSONException ignore) {
                    LOG.e(TAG, "Invalid boolean argument");
                }
            });
            return true;
        }

        if (ACTION_STYLE_DEFAULT.equals(action)) {
            this.cordova.getActivity().runOnUiThread(() -> setStatusBarStyle(STYLE_DEFAULT));
            return true;
        }

        if (ACTION_STYLE_LIGHT_CONTENT.equals(action)) {
            this.cordova.getActivity().runOnUiThread(() -> setStatusBarStyle(STYLE_LIGHT_CONTENT));
            return true;
        }

        return false;
    }

    private void setStatusBarBackgroundColor(final String colorPref) {
        if (colorPref != null && !colorPref.isEmpty()) {
            final Window window = cordova.getActivity().getWindow();
            // Method and constants not available on all SDKs but we want to be able to compile this code with any SDK
            window.clearFlags(0x04000000); // SDK 19: WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            window.addFlags(0x80000000); // SDK 21: WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            try {
                // Using reflection makes sure any 5.0+ device will work without having to compile with SDK level 21
                window.getClass().getMethod("setStatusBarColor", int.class).invoke(window, Color.parseColor(colorPref));
            } catch (IllegalArgumentException ignore) {
                LOG.e(TAG, "Invalid hexString argument, use f.i. '#999999'");
            } catch (Exception ignore) {
                // this should not happen, only in case Android removes this method in a version > 21
                LOG.w(TAG, "Method window.setStatusBarColor not found for SDK level " + Build.VERSION.SDK_INT);
            }
        }
    }

    private void setStatusBarTransparent(final boolean transparent) {
        final Window window = cordova.getActivity().getWindow();
        if (transparent) {
            window.getDecorView().setSystemUiVisibility(
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                    | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN);
            window.setStatusBarColor(Color.TRANSPARENT);
        }
        else {
            window.getDecorView().setSystemUiVisibility(
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                    | View.SYSTEM_UI_FLAG_VISIBLE);
        }
    }

    private void setStatusBarStyle(final String style) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !style.isEmpty()) {
            Window window = cordova.getActivity().getWindow();
            View decorView = window.getDecorView();
            WindowInsetsControllerCompat windowInsetsControllerCompat = WindowCompat.getInsetsController(window, decorView);

            if (style.equals(STYLE_DEFAULT)) {
                windowInsetsControllerCompat.setAppearanceLightStatusBars(true);
            } else if (style.equals(STYLE_LIGHT_CONTENT)) {
                windowInsetsControllerCompat.setAppearanceLightStatusBars(false);
            } else {
                LOG.e(TAG, "Invalid style, must be either 'default' or 'lightcontent'");
            }
        }
    }
}
