package com.lengdev.facedetector

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.ByteArrayOutputStream
import android.util.Log
import kotlinx.coroutines.*

/** FaceBoundingBoxDetectorPlugin */
class FaceBoundingBoxDetectorPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var faceDetector: FaceDetector? = null
    private lateinit var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        this.flutterPluginBinding = flutterPluginBinding
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "face_bounding_box_detector")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            
            "initialize" -> {
                initialize(result)
            }
            "detectFromImage" -> {
                val imageBytes = call.argument<ByteArray>("imageBytes")
                if (imageBytes != null) {
                    detectFromImage(imageBytes, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Image bytes are required", null)
                }
            }
            "detectFromYuv" -> {
                val yuvBytes = call.argument<ByteArray>("yuvBytes")
                val width = call.argument<Int>("width")
                val height = call.argument<Int>("height")
                val orientation = call.argument<Int>("orientation") ?: 0
                
                if (yuvBytes != null && width != null && height != null) {
                    detectFromYuv(yuvBytes, width, height, orientation, result)
                } else {
                    result.error("INVALID_ARGUMENT", "YUV bytes, width, and height are required", null)
                }
            }
            "destroy" -> {
                destroy(result)
            }
            
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun initialize(result: Result) {
        CoroutineScope(Dispatchers.Default).launch {
            try {
                if (faceDetector != null) {
                    faceDetector?.destroy()
                    faceDetector = null
                }
                faceDetector = FaceDetector()
                val loadResult = faceDetector?.loadModel(flutterPluginBinding.applicationContext.assets)
                
                withContext(Dispatchers.Main) {
                    if (loadResult == 0) {
                        result.success(true)
                    } else {
                        result.error("INITIALIZATION_ERROR", "Failed to initialize detector!.", null)
                    }
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("INITIALIZATION_ERROR", "Failed to initialize detector: ${e.message}", null)
                }
            }
        }
    }

    private fun detectFromImage(imageBytes: ByteArray, result: Result) {
        CoroutineScope(Dispatchers.Default).launch {
            try {
                if (faceDetector == null) {
                    withContext(Dispatchers.Main) {
                        result.error("NOT_INITIALIZED", "Detector not initialized", null)
                    }
                    return@launch
                }
                
                val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
                if (bitmap == null) {
                    withContext(Dispatchers.Main) {
                        result.error("INVALID_IMAGE", "Failed to decode image", null)
                    }
                    return@launch
                }
                
                // Convert to ARGB_8888 if needed
                val argbBitmap = if (bitmap.config != Bitmap.Config.ARGB_8888) {
                    bitmap.copy(Bitmap.Config.ARGB_8888, false)
                } else {
                    bitmap
                }
                
                val faces = faceDetector?.detect(argbBitmap)

                val faceList = faces?.map { faceBoxToMap(it) } ?: emptyList()
                
                bitmap.recycle()
                if (argbBitmap != bitmap) {
                    argbBitmap.recycle()
                }
                
                withContext(Dispatchers.Main) {
                    result.success(faceList)
                }
            } catch (e: Exception) {
                Log.d("Face Detector", "Detection failed: ${e.message}")
                withContext(Dispatchers.Main) {
                    result.error("DETECTION_ERROR", "Detection failed: ${e.message}", null)
                }
            }
        }
    }

    private fun detectFromYuv(
        yuvBytes: ByteArray,
        width: Int,
        height: Int,
        orientation: Int,
        result: Result
    ) {
        CoroutineScope(Dispatchers.Default).launch {
            try {
                
                if (faceDetector == null) {
                    withContext(Dispatchers.Main) {
                        result.error("NOT_INITIALIZED", "Detector not initialized", null)
                    }
                    return@launch
                }
                
                val faces = faceDetector?.detect(yuvBytes, width, height, orientation)
                val faceList = faces?.map { faceBoxToMap(it) } ?: emptyList()
                
                withContext(Dispatchers.Main) {
                    result.success(faceList)
                }
            } catch (e: IllegalArgumentException) {
                withContext(Dispatchers.Main) {
                    result.error("INVALID_ARGUMENT", e.message, null)
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("DETECTION_ERROR", "Detection failed: ${e.message}", null)
                }
            }
        }
    }

    private fun destroy(result: Result) {
        CoroutineScope(Dispatchers.Default).launch {
            try {
                faceDetector?.destroy()
                faceDetector = null
                withContext(Dispatchers.Main) {
                    result.success(true)
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("DESTROY_ERROR", "Failed to destroy detector: ${e.message}", null)
                }
            }
        }
    }

    private fun faceBoxToMap(faceBox: FaceBox): Map<String, Any> {
        return mapOf(
            "x" to faceBox.left,
            "y" to faceBox.top,
            "right" to faceBox.right,
            "bottom" to faceBox.bottom,
            "confidence" to (faceBox.confidence ?: 0.0)
        )
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        faceDetector?.destroy()
        faceDetector = null
    }
}