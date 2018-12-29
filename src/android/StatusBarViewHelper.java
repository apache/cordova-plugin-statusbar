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
import android.graphics.Rect;
import android.util.Log;
import android.view.View;
import android.view.ViewTreeObserver;
import android.widget.FrameLayout;

/*
    Issue ID: CB-13300
    This happens when the status bar is in overlay mode, because to get transparent
    status bars in Android, you need to use a full screen layout, which prevents
    the webview from adjusting automatically.

    This class watches for layout changes and resizes the webview based on 
    status bar, navigation bar (android phones without physical navigation buttons), 
    and keyboard states to prevent the keyboard from overlapping content when shown.
 */
public class StatusBarViewHelper {
    private View mChildOfContent;
    private int usableHeightPrevious;
    private FrameLayout.LayoutParams frameLayoutParams;
    private Activity activity;

    static void assistActivity(Activity activity) {
        new StatusBarViewHelper(activity);
    }

    private StatusBarViewHelper(Activity a) {
        activity = a;
        FrameLayout content = (FrameLayout) activity.findViewById(android.R.id.content);
        mChildOfContent = content.getChildAt(0);

        mChildOfContent.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            public void onGlobalLayout() {
                possiblyResizeChildOfContent();
            }
        });

        frameLayoutParams = (FrameLayout.LayoutParams) mChildOfContent.getLayoutParams();
    }

    private void possiblyResizeChildOfContent() {
        int usableHeightNow = computeUsableHeight();
        if (usableHeightNow != usableHeightPrevious) {
            frameLayoutParams.height = usableHeightNow;
            mChildOfContent.requestLayout();
            usableHeightPrevious = usableHeightNow;
        }
    }

    private int computeUsableHeight() {
        Rect r = new Rect();
        mChildOfContent.getWindowVisibleDisplayFrame(r);
        int uiOptions = activity.getWindow().getDecorView().getSystemUiVisibility();
        boolean isFullscreen = ((uiOptions | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN) == uiOptions);

        //If not fullscreen, then we have to take the status bar into consideration (represented by r.top)
        //r.bottom defines the keyboard, or navigation bar, or both.

        return isFullscreen ? r.bottom : r.bottom - r.top;
    }
}
