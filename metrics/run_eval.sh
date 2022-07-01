DIR=./demo_lang8_lyy

python pair2edits_char.py $DIR/src.txt $DIR/hyp.txt > $DIR/output.txt

perl evaluation.pl $DIR/output.txt $DIR/report.txt $DIR/ref.txt
