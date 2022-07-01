# Step1. Data Preprocessing
SRC_FILE="../../data/lang8.train.ccl22.src" # 每行一个病句
TGT_FILE="../../data/lang8.train.ccl22.tgt"  # 每行一个正确句子，和病句一一对应
LABEL_FILE="../../data/train_data/lang8+hsk/train.label"  # 训练数据

# Step2. Training
CUDA_DEVICE=0
SEED=1

DEV_SET="../../data/dev_data/dev.label"
MODEL_DIR="./exps/seq2edit_lang8_lyy1"
if [ ! -d $MODEL_DIR ]; then
  mkdir -p $MODEL_DIR
fi

PRETRAIN_WEIGHTS_DIR=./plm/chinese-struct-bert-large

VOCAB_PATH=./data/output_vocabulary_chinese_char_hsk+lang8_5

## Freeze encoder (Cold Step)
COLD_LR=1e-3
COLD_BATCH_SIZE=128
COLD_MODEL_NAME=Best_Model_Stage_1
COLD_EPOCH=2

CUDA_VISIBLE_DEVICES=$CUDA_DEVICE python train.py --tune_bert 0\
                --train_set $LABEL_FILE".shuf"\
                --dev_set $DEV_SET\
                --model_dir $MODEL_DIR\
                --model_name $COLD_MODEL_NAME\
                --vocab_path $VOCAB_PATH\
                --batch_size $COLD_BATCH_SIZE\
                --n_epoch $COLD_EPOCH\
                --lr $COLD_LR\
                --weights_name $PRETRAIN_WEIGHTS_DIR\
                --seed $SEED

## Unfreeze encoder
LR=1e-5
BATCH_SIZE=32
ACCUMULATION_SIZE=4
MODEL_NAME=Best_Model_Stage_2
EPOCH=20
PATIENCE=3

CUDA_VISIBLE_DEVICES=$CUDA_DEVICE python train.py --tune_bert 1\
                --train_set $LABEL_FILE".shuf"\
                --dev_set $DEV_SET\
                --model_dir $MODEL_DIR\
                --model_name $MODEL_NAME\
                --vocab_path $VOCAB_PATH\
                --batch_size $BATCH_SIZE\
                --n_epoch $EPOCH\
                --lr $LR\
                --accumulation_size $ACCUMULATION_SIZE\
                --patience $PATIENCE\
                --weights_name $PRETRAIN_WEIGHTS_DIR\
                --pretrain_folder $MODEL_DIR\
                --pretrain "Temp_Model"\
                --seed $SEED
