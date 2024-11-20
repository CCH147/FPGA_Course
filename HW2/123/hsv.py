import cv2
import numpy as np

def hsv(image, lower, upper):
    # 轉換為HSV色彩空間
    hsv_image = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
    # 使用顏色範圍進行遮罩
    mask = cv2.inRange(hsv_image, lower, upper)
    # 將遮罩應用於影像
    result = cv2.bitwise_and(image, image, mask=mask)
    return result
