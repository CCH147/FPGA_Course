import cv2
import numpy as np
from collections import deque
from matplotlib import pyplot as plt

import sobel
import hsv
import lbp
import histogram 
import one_norm_dist
import labeling
def main():
    radius = 1
    n_points = 8  
    patch_size = 10  
    # 讀取影像
    image = cv2.imread('C:\\FPGA\\FPGA_Course\\HW2\\123\\way.jpg')
    #image_gray = cv2.imread('test.jpg',0)
    
    #HSV
    lower = np.array([0, 0, 0])   
    upper = np.array([180, 200, 100])  
    hsv_img = hsv.hsv(image, lower, upper)
    cv2.imwrite('hsv.jpg',hsv_img)
    image_gray = cv2.imread('hsv.jpg',0)
    
    #sobel
    Sobel_img = sobel.sobel(image_gray)
    cv2.imwrite('sobel.jpg',Sobel_img)

    #lbp
    lbp_img = lbp.lbp(Sobel_img)
    cv2.imwrite('lbp.jpg',lbp_img)


    #histogram
    mask = np.zeros_like(image_gray)  
    #histogram找前三大(設定閥值)
    his = histogram.calculate_histogram(lbp_img)
    hist = histogram.plot_histogram(his)
    top3 = histogram.find_top_three(his)
    th = int(sum(top3)/3)
    
    rows, cols = image_gray.shape
    for i in range(0, rows, patch_size):
        for j in range(0, cols, patch_size):
            patch1 = image_gray[i:i+patch_size, j:j+patch_size]
            if i+patch_size < rows and j+patch_size < cols:
                # 與右邊的區塊進行比較
                patch2 = image_gray[i:i+patch_size, j+patch_size:j+2*patch_size]
                hist1 = histogram.calculate_histogram(patch1)
                hist2 = histogram.calculate_histogram(patch2)               
                if one_norm_dist.calculate_1_norm_distance(hist1, hist2) <= th:
                    mask[i:i+patch_size, j:j+patch_size] = 1  
    #labeling
    colored_img = labeling.label_areas(image, mask)

    cv2.imwrite('final.jpg',colored_img)    
    
    # 顯示
    # 原始影像和著色後的影像
    cv2.imshow('Colored Image', colored_img)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

if __name__ == '__main__':
    main()