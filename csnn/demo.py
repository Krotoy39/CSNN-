# 陈健中
# 开发时间：2023/6/25 9:51
import numpy as np
import pandas as pd
from cnn_picture import *


def HUST():
    img = np.zeros((4, 25))
    img[0] = [1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1]  # H
    img[1] = [1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1]  # U
    img[2] = [0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0]  # S
    img[3] = [1, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0]  # T

    return img


def encoding(image):
    image = image.reshape((-1, 1))
    p_x, p_y = image.shape
    spikes = np.zeros((p_x, p_y))
    for i in range(p_x):
        for j in range(p_y):
            if image[i,j] >= 1:
                spikes[i, j] = 3
            else:
                spikes[i, j] = 0

    return spikes


def f_encoding(image):
    image = image.reshape((-1, 1))
    p_x, p_y = image.shape
    spikes = np.zeros((p_x, p_y))
    for i in range(p_x):
        for j in range(p_y):
            if image[i, j] >= 1:
                spikes[i, j] = 10
            else:
                spikes[i, j] = 0

    return spikes


def main():
    os.environ['KMP_DUPLICATE_LIB_OK'] = 'True'
    chose_num = 0
    images = HUST()
    cnn_kernel = synapse(2, 8)
    N = Neurons(8, 20)              # 类第一个参数为神经元数目,第二个参数为bacth
    for epoch in range(10):
        for batch in range(10):
            plt.figure(epoch)
            # for chose_num in range(4):
            input_v = encoding(images[chose_num])
            # plt.figure()
            # plt.imshow(input_v.reshape((5, 5)))
            # plt.axis("off")
            # plt.show()

            input_f = f_encoding(images[chose_num])  # 编码

            # plt.figure()
            # plt.imshow(np.reshape(images[chose_num], (28, 28)))
            # plt.show()

            out_spike, filed = cnn_kernel.cnn(input_v)  # 需要额外使用一个filed
            # out_spike = cnn_kernel.pooling(out_spike)         # 经历卷积层和池化层后输入神经元

            out_spike = N.Compilation(out_spike)  # 将数据维度变为8*144
            time, n = out_spike.shape  # time输入神经元时间维度,n指输入神经元数量
            # 需要重新编译动态阈值
            cnn_kernel.dynamic_thresholds(filed)
            # 需要一个全局变量,记录神经元的输出信息
            feature_map = np.zeros((N.neuron_number, time))
            for i in range(time):
                N.run_neurons(out_spike[i, :])
                feature_map[:, i] = N.f_output  # feature_map的维度应该是

            # 如果使用SRDP的话需要将input也做卷积和池化处理
            cnn_kernel.dynamic_SRDP(filed, feature_map)  # 关于冒号的使用是不取最后一个数值的
            # 换种方式plt.show,应该看一个卷积核的
            # for j in range(cnn_kernel.kernel_num):
            #     plt.subplot(2, 4, j + 1)
            #     plt.imshow(feature_map[j, :].reshape(4, 4))
            #     plt.axis('off')
            # 更新权重
            for i in range(cnn_kernel.kernel_num):
                plt.subplot(2, 4, i + 1)
                plt.imshow(cnn_kernel.G[:, i].reshape(2, 2))
                plt.axis('off')
        cnn_kernel.Update()
        plt.show()
    # data = pd.DataFrame(cnn_kernel.G)
    # writer = pd.ExcelWriter(r'C:\Users\czy\Desktop\csnn\数据\synapse.xlsx')
    # data.to_excel(writer)
    # writer.save()
    # writer.close()


if __name__ == "__main__":
    main()