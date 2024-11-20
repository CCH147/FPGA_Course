import cv2
import numpy as np

def sobel(image_gray):
    # 使用Sobel邊緣檢測
    sobel_x = cv2.Sobel(image_gray, cv2.CV_64F, 1, 0, ksize=3)
    sobel_y = cv2.Sobel(image_gray, cv2.CV_64F, 0, 1, ksize=3)
    sobel = cv2.magnitude(sobel_x, sobel_y)
    sobel = cv2.convertScaleAbs(sobel)

    # 應用形態學運算以清理結果
    kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (5, 5))
    sobel_morph = cv2.morphologyEx(sobel, cv2.MORPH_CLOSE, kernel)
    
    return sobel_morph
