package com.lengdev.facedetector

import android.content.res.AssetManager
import android.graphics.Bitmap
import android.util.Log
import androidx.annotation.Keep
import java.lang.IllegalArgumentException

@Keep
class FaceDetector {

    @Keep
    private var nativeHandler: Long

    init {
        try {
            System.loadLibrary("facedetector")
            libraryFound = true
            Log.d(tag, "Library loaded successfully!")
        } catch (e: UnsatisfiedLinkError) {
            e.printStackTrace()
        }

        // Create native instance
        nativeHandler = createInstance()
    }

    private fun createInstance(): Long = allocate()

    fun destroy() = deallocate()

    fun loadModel(assetsManager: AssetManager): Int = nativeLoadModel(assetsManager)

    fun detect(bitmap: Bitmap): List<FaceBox> = when (bitmap.config) {
        Bitmap.Config.ARGB_8888 -> nativeDetectBitmap(bitmap)
        else -> throw IllegalArgumentException("Invalid bitmap config value")
    }

    fun detect(
        yuv: ByteArray,
        previewWidth: Int,
        previewHeight: Int,
        orientation: Int
    ): List<FaceBox> {
        if (previewWidth * previewHeight * 3 / 2 != yuv.size) {
            throw IllegalArgumentException("Invalid yuv data")
        }
        return nativeDetectYuv(yuv, previewWidth, previewHeight, orientation)
    }

    //////////////////////////////// Native ////////////////////////////////////
    @Keep
    private external fun allocate(): Long

    @Keep
    private external fun deallocate()

    @Keep
    private external fun nativeLoadModel(assetsManager: AssetManager): Int

    @Keep
    private external fun nativeDetectBitmap(bitmap: Bitmap): List<FaceBox>

    @Keep
    private external fun nativeDetectYuv(
        yuv: ByteArray,
        previewWidth: Int,
        previewHeight: Int,
        orientation: Int
    ): List<FaceBox>

    companion object {
        var libraryFound: Boolean = false
        const val tag = "FaceDetector"
    }
}
