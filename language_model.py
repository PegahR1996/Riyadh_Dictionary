import fasttext.util
import os

model_dir = "/app/models"

old_dir = os.getcwd()

os.chdir(model_dir)

os.makedirs(model_dir, exist_ok=True)

model_path = fasttext.util.download_model('ar', if_exists='ignore', download_dir=model_dir)
ArabicWE = fasttext.load_model(model_path)

os.chdir(old_dir)


def ArabicWEFunction(Word):
    return list(ArabicWE[Word])


def SimilarWords(Word):
    if Word in ArabicWE.get_words():
        words_difference = {}
        for each_word in ArabicWE.get_words()[:10000]:
            words_difference[each_word] = sum(
                [abs(float(i) - float(j)) for i, j in
                 zip([i for i in ArabicWE[Word]], [i for i in ArabicWE[each_word]])]
            )
            #
        sorted_words = sorted(words_difference.items(), key=lambda item: item[1])
        # out=sorted_words
        out = [x[0] for x in sorted_words]
        return out[1:6]
    else:
        return [('Word not found', 0.0)]  # Return a tuple indicating that the word was not found
