# 陈健中
# 开发时间：2022/5/26 9:18
import numpy as np
import math
import matplotlib.pyplot as plt

from picture import *

class convolution_kernel(synapse):
    def __init__(self):
        self.kernel_num = 8
        self.dimension = 5

        # 卷积核为5*5阵列，输出为一个卷积后的值
        self.input_number = 25
        self.output_number = 1

        # 测试用卷积核
        np.random.seed(1)
        self.text_kernel = np.random.randn(1,25)

    def convolution_computing(self, signal):
        # 先确定将signal的感受野

        # 卷积核滑动的步长为1,填充为0,28*28的数据，卷积核5*5,卷积后的矩阵24*24

        # 将output做一个空array暂存
        output = np.zeros((24,24))

        # 卷积滑动一行,i为行,j为列
        for i in range(24):
            for j in range(24):

                # 使用一个空的数组暂存感受野
                filed = []

                for ker_len in range(5):
                    for ker_queue in range(5):

                        filed.append(signal[i+ker_len, j+ker_queue])

                # 做卷积算出每一个点的值
                filed = np.array(filed).reshape(25, 1)
                output[i, j] = np.dot(self.text_kernel, filed)

        return output

def dot_mul(x, y):

    # 将x,y的维度提取出来,备注,x_queue应该等于y_line
    x_line, x_queue = x.shape
    y_line, y_queue = y.shape

    output = np.zeros((x_line, y_queue))
    for line in range(x_line):
        for queue in range(y_queue):
            dot_a = x[line, :]
            dot_b = y[:, queue]
            output[line, queue] = sum(dot_a * dot_b)

    return output

if __name__ == "__main__":

    # 从写好的图片处理模块中抽调出get_image函数
 
    labels, images = get_image()

    kernel_num = 8

    signal = images[6000].reshape(28, 28)
    '''
    # 创建卷积核
    Cnn = convolution_kernel()

    output = Cnn.convolution_computing(signal)

    plt.imshow(output)
    plt.show()
    '''
    x = np.ones((3, 2))
    y = np.ones((2, 4))

    z = dot_mul(x, y)
    print(z)











