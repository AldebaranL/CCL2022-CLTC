
CUDA_DEVICE=0
SEED=1

MODEL_DIR="./exps/seq2edit_lang8_lyy1"
MODEL_PATH="$MODEL_DIR/Best_Model_Stage_2.th"
RESULT_DIR="$MODEL_DIR/results"
PRETRAIN_WEIGHTS_DIR=./plm/chinese-struct-bert-large
VOCAB_PATH=./data/output_vocabulary_chinese_char_hsk+lang8_5

INPUT_FILE="../../data/test_data/test_2021.src" # 输入文件
if [ ! -f "$INPUT_FILE.char" ]; then
    python ../../tools/segment/segment_bert.py < $INPUT_FILE > "$INPUT_FILE.char"  # 分字
fi
if [ ! -d $RESULT_DIR ]; then
  mkdir -p $RESULT_DIR
fi
OUTPUT_FILE="$RESULT_DIR/test_2021.output"

echo "Generating..."
SECONDS=0
CUDA_VISIBLE_DEVICES=$CUDA_DEVICE python predict.py --model_path $MODEL_PATH\
                  --weights_name $PRETRAIN_WEIGHTS_DIR\
                  --vocab_path $VOCAB_PATH\
                  --input_file $INPUT_FILE".char"\
                  --output_file $OUTPUT_FILE --log

echo "Generating Finish!"
duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."