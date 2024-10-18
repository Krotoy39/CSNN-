# 陈健中
# 开发时间：2023/5/8 15:19
import os
import time
import math
import torch.nn
import torchvision
import torch.optim as optim
import matplotlib.pyplot as plt
from torchvision import datasets
import torchvision.transforms as transforms
from torch import nn
from tensorboardX import SummaryWriter
from torch.utils.data import DataLoader
from cnn_picture import *


class ConvSnn(nn.Module):
    def __init__(self):
        super(ConvSnn, self).__init__()

        self.conv1 = nn.Sequential(

        )
        self.fc = nn.Sequential(

        )

    def forward(self, x):
        x = self.conv1(x)
        output = self.fc(x.view(-1, 256 * 6 * 6))
        return output


def weight_init(m):
    if isinstance(m, nn.Linear):                                        # isinstance python中的内置函数,表示判断变量的数据类型
        nn.init.xavier_normal_(m.weight)
        nn.init.constant_(m.bias, 0)

    elif isinstance(m, nn.BatchNorm2d):
        nn.init.constant_(m.weight, 1)
        nn.init.constant_(m.bias, 0)

    # elif isinstance(m, synapse):                                        # 这为自设突触全权重更新,默认synapse是一种数据类型
    #     nn.init.constant_(m.weight)


def visuialize(images):
    os.environ['KMP_DUPLICATE_LIB_OK'] = 'True'
    print(images.numpy().shape)
    plt.figure()
    plt.subplot(131)
    plt.imshow(images[0])
    plt.subplot(132)
    plt.imshow(images[1])
    plt.subplot(133)
    plt.imshow(images[2])
    plt.show()


def train():
    transform = transforms.Compose([                                                    # Comose函数将几个步骤整合在一起
        transforms.Resize(256),                                                         # 重置给定的图片size
        transforms.CenterCrop(224),                                                     # 在图片的中间区域进行裁剪
        transforms.ToTensor(),                                                          # 相当于转为灰度图
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),    # 初始化
    ])

    train_set = datasets.cifar.CIFAR100(
        root=r'C:\Users\czy\Desktop\csnn\dataset\CIFAR100', train=True, transform=transform,
        download=True)
    test_set = datasets.cifar.CIFAR100(
        root=r'C:\Users\czy\Desktop\csnn\dataset\CIFAR100', train=False, transform=transform,
        download=True)

    train_loader = torch.utils.data.DataLoader(train_set, batch_size=384, num_workers=4, shuffle=True, pin_memory=True,
                                               drop_last=True)
    # batch_size是每次抛出的样本数量,num_workers是多线程的使用数量,shuffle=True是打乱数据,一定要注意输入进函数的数据是可以迭代的,pin_memory是True的意思是
    # 将数据导入cuda,drop_last的意思是跳过最后的batch不足384的数据。

    test_loader = torch.utils.data.DataLoader(test_set, batch_size=384, num_workers=4, shuffle=False, pin_memory=True,
                                              drop_last=True)

    writer = SummaryWriter(r'C:\Users\czy\Desktop\csnn\data\CIFAR10\CNN_CIFAR10_0')
    train_data_size = len(train_set)
    test_data_size = len(test_set)
    print("训练数据集的长度为：{}".format(train_data_size))                                  # train_data_size为50000
    print("测试数据集的长度为：{} \n".format(test_data_size))                                # test_data_size为10000

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model = ConvSnn()
    model.to(device)
    model.apply(weight_init)

    # 记录训练的轮数
    total_train_step = 0
    # 记录测试的次数
    total_test_step = 0
    # 控制训练轮数
    epochs = 60

    start_time = time.time()
    for epoch in range(epochs):
        print("-----第{}轮训练开始-----".format(epoch + 1))
        model.train()
        global train_loss
        train_loss = 0
        for idx, (inputs, label) in enumerate(train_loader):
            inputs, label = inputs.to(device), label.to(device)
            outputs = model(inputs)
            # visuialize(inputs)


if __name__ == "__main__":
    train()