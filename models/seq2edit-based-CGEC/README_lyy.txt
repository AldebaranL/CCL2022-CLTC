GECToR的中文版。
1. 数据处理（使用lang8数据集，共1213457个句子对）
    错句每句一行 文件：../../data/lang8.train.ccl22.src
    对应的正确句每句一行 文件：../../data/lang8.train.ccl22.tgt
        其对应的.char文件为分词后的结果
        （这里是按字级别，具见../../tools/segment/segment_bert.py）
    将上述两个文件输入./utils/preprocess_data.py进行数据处理，得到一个带tag的文件：
        ../../data/train_data/lang8+hsk/data_all.label
    将data_all.label按8：2的比例划分为train set和dev set，分别为：
        ../../data/train_data/lang8+hsk/train.label
        ../../data/dev_data/dev.label
    .label为GECToR模型的唯一数据输入。

2. 下载预训练的bert模型用于encode：./plm/chinese-struct-bert-large/pytorch_model.bin

3. bash ./train.sh即可进行模型训练
    模型训练分为两个阶段。每个epoch的模型都会被暂存在$MODEL_DIR/Temp_Model.th中。
    第一阶段，运行了2个epoch，输入bert作为预训练模型。
    第二阶段，运行了20个epoch，输入当时的$MODEL_DIR/Temp_Model.th作为预训练模型。（因为第一阶段的第二次结果一般好于第一次）
    调用的模型为../../models/seq2edit-based-CGEC/gector/seq2labels_model.py中的Seq2Labels。
    Seq2Labels模型即由输入的embedding经过一个或多个（大小相同的）线性层映射到tags（如$KEEP等）
    
    分成两个阶段的目的是（先Lang8+Hsk再单独Hsk）所得模型效果相较于单阶段训练效果会有进一步提升，
        但这里由于数据集权限所限，两个阶段均使用同样的Lang8数据集进行训练。（所以只用一阶段也可以）

    最终训练好的模型即为$MODEL_DIR/Best_Model_Stage_2.th

注：如果不进行训练，直接使用checkpoints，在预测时直接指定Best_Model_Stage_2.th即可。

4. bash ./predict.sh即可进行预测（使用CCL2021数据集进行测试）
    输入文件：INPUT_FILE="../../data/test_data/test_2021.src" 
    调用../../models/seq2edit-based-CGEC/gector/gec_model.py中的GecBERTModel，这是一个用于多模型集成的类
    运行predict.sh后会在%MODEL_DIR/result中有.output和.output.char文件，为输入文件对应的每句改正结果和改正+分词结果。

# GECToR源代码提供了两种模型，分别是：1）gec_model.py; 2）seq2labels_model.py
# 真正意义上，GECToR进行预测和训练使用的是seq2labels模型，它是一个简单的encoder+classifier架构的模型，用于标注一个编辑序列（encode+tag）。
# 而模型集成、利用编辑序列获得目标序列、恢复模型等操作的逻辑，被作者写在了GecBERTModel这个类里。
# 它相当于对seq2labels模型的高级封装，用于使用训练好的seq2labels模型预测并输出纠错结果。
# 训练阶段，我们只训练seq2labels模型；而预测阶段，我们才需要用到完整的gec_model模型。

5. 获得得分：../../metrics/run_eval.sh
    把刚刚$MODEL_DIR/result中的test_2021.output.char复制到./../metrics/demo/下，重命名为hyp.txt
    然后运行../../metrics/run_eval.sh，得分报告会生成为../../metrics/demo/report.txt