import cv2
import numpy as np
from matplotlib import pyplot as plt

def calculate_histogram(image):
    hist = cv2.calcHist([image], [0], None, [256], [0, 256])
    return hist

def plot_histogram(hist):
    plt.plot(hist)
    plt.xlabel('Pixel value')
    plt.ylabel('Frequency')
    plt.title('Histogram')
    plt.show()

def find_top_three(hist):
    sorted_values = sorted(hist.flatten(), reverse=True)
    top_three = [int(idx) for  idx in sorted_values]
    return top_three
