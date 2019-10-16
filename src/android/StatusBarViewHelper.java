package org.apache.cordova.statusbar;

import android.app.Activity;
import android.graphics.Rect;
import android.view.View;
import android.view.ViewTreeObserver;
import android.widget.FrameLayout;

public class StatusBarViewHelper {

    // For more information, see https://issuetracker.google.com/issues/36911528
    // To use this class, simply invoke assistActivity() on an Activity that already has its content view set.

    //This solution was based off of
    //https://stackoverflow.com/questions/7417123/android-how-to-adjust-layout-in-full-screen-mode-when-softkeyboard-is-visible/19494006#answer-42261118

    private View mChildOfContent;
    private int usableHeightPrevious;
    private FrameLayout.LayoutParams frameLayoutParams;
    private Activity activity;
    private StatusBar statusbar;
    private static final String TAG = "StatusBarViewHelper";

    static void assist(Activity activity, StatusBar statusbar) {
        new StatusBarViewHelper(activity, statusbar);
    }

    private StatusBarViewHelper(Activity a, StatusBar b) {
        activity = a;
        statusbar = b;

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

    private boolean _isStatusBarVisible() {
        return statusbar.isVisible();
    }

    private int computeUsableHeight() {
        Rect r = new Rect();
        mChildOfContent.getWindowVisibleDisplayFrame(r);
        int uiOptions = activity.getWindow().getDecorView().getSystemUiVisibility();
        boolean isFullscreen = ((uiOptions | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN) == uiOptions);
        boolean isStatusBarVisible = this._isStatusBarVisible();

        int usableHeight = r.bottom;

        // This handles both overlayed status bars and reserved spaces for cutouts when the
        // status bar is hidden
        if (!isFullscreen || (isFullscreen && !isStatusBarVisible)) {
            usableHeight = usableHeight - r.top;
        }

        return usableHeight;
    }
}
