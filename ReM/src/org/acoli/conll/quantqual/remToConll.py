# -*- coding: utf-8 -*-
"""
 * Copyright [2017] [ACoLi Lab, Prof. Dr. Chiarcos, Goethe University Frankfurt]
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
"""
"""
Created on 09.02.2017

@author: Benjamin Kosmehl

Convert CoraXML XML files from the ReM corpus into CoNLL format.
The transformation is done using the tags in the XML tree defined in variable "tagz" as well as punctuation and id as columns.

TODO: insert file meta information as comment into CoNLL
"""
from lxml import etree  # @UnresolvedImport#
from time import time
from os import listdir, path, makedirs
import codecs
import argparse
import logging
import re
import sys

logger = logging.getLogger()

def processSrcFile(filePath, outDir, fileName):
    logger.info("processing %s", fileName)

    if filePath == sys.stdin:
        etree.parse(sys.stdin)
    else:
        srcStuff = etree.parse(path.join(filePath, fileName))
    srcRoot = srcStuff.getroot()

    if outDir == sys.stdout:
        f = outDir
    else:
        h = srcRoot.find("header")

    gen = h.find("genre")
    s = ""
    if gen is None or (not(gen.text == "-")) or (not(gen.text != "")) or (gen.text is None):

        global fileNameTimeGenreFlag
        if fileNameTimeGenreFlag:
            s = "None"
            genstr = gen.text if gen is not None else s

            #12,2-13,1
            tim = h.find("time")
            timstr="xx-x"
            if (tim is None) or (tim.text == "-") or (tim.text == "") or (tim.text is None):
                try:
                    tim=tim.text
                except: pass
                sys.stderr.write("time tag missing or malformed for " + fileName+": "+str(tim)+"\n")
                sys.stderr.flush()
            else:
                timstr = tim.text[:4] if len(tim.text) > 2 else (tim.text + ",1")
                timstr = timstr.replace(",", "-")

            if genstr==None:
                genstr="x"
            out = path.join(outDir, re.sub("\.[\w]{2,4}$", "_"+str(timstr)+"_"+str(genstr)+".conll", fileName))
        else:
            out = path.join(outDir, re.sub("\.[\w]{2,4}$", ".conll", fileName))
        makedirs(path.dirname(out), exist_ok=True)
        if path.isfile(out):
            open(out, "w").close()
        f = codecs.open(out, "a", "utf-8")
    sentenceBuffer = []

    # tags used below tok_anno
    tagz = ["norm", "lemma", "pos", "infl", "punc"]
    # column header
    f.write(u"#ID\tTID\tWORD\tLEMMA\tPOS\tINFL\tSB\n")

    sentenceBuffer.append(u"")
    sentenceEndFlag = False
    sentenceInternalTokenID = 1

    for c in srcRoot.findall("token"):
        tok_annos = [elem for elem in c.iter() if elem.tag == "tok_anno"]
        if not tok_annos:
            logger.critical("data structure corrupted at {0} line {1}", fileName, srcRoot.index(c))
            break

        for x in range(len(tok_annos)):
            tok_anno = tok_annos[x]
            punc = tok_anno.find("punc")

            if sentenceEndFlag and (punc is None or not (punc.attrib["tag"].endswith("E") and c.attrib["type"] == "punc")):
                sentenceBuffer.append(u"\n")
                f.write(u"\n".join(sentenceBuffer))
                sentenceBuffer.clear()
                sentenceEndFlag = False
                sentenceInternalTokenID = 1

            line = u"" + str(sentenceInternalTokenID)
            line = line + "\t" + c.attrib["id"] + "_" + "{0:0=3d}".format(x)
            #line = line + "\t" + d.attrib["ascii"]
            #line = line + "\t" + d.attrib["trans"]
            for t in tagz:
                ct = tok_anno.find(t)
                cv = "-"
                if ct is not None:
                    cv = ct.attrib["tag"]
                    if cv == "--":
                        cv = "-"
                line = line + "\t" + cv.replace(u"#", u"-")

            sentenceBuffer.append(line)
            sentenceInternalTokenID = sentenceInternalTokenID + 1

            if punc is not None:
                if punc.attrib["tag"].endswith("E"):
                    sentenceEndFlag = True

    if sentenceEndFlag:
        sentenceBuffer.append(u"\n")
        f.write(u"\n".join(sentenceBuffer))
        sentenceBuffer.clear()
        sentenceEndFlag = False

    f.close()

def initializeLogger(logPath, fileName, loglevelFile = logging.DEBUG, loglevelConsole = logging.INFO, propagate = True):
    rootLogger = logging.getLogger()
    if propagate:
        rootLogger.setLevel(loglevelFile)
        logFormatter = logging.Formatter("%(asctime)s [%(threadName)-12.12s] [%(levelname)-7.7s]  %(message)s")

        fileHandler = logging.FileHandler("{0}/{1}.log".format(logPath, fileName))
        fileHandler.setFormatter(logFormatter)
        rootLogger.addHandler(fileHandler)

        consoleHandler = logging.StreamHandler()
        consoleHandler.setLevel(loglevelConsole)

        rootLogger.addHandler(consoleHandler)
    rootLogger.propagate = propagate

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Convert ReM CorA-XML to CoNLL format.")
    parser.add_argument("-mode", default="dirdir", help="set mode for input and output (\"dirdir\" default) - combination of \"stdin\" \"stdout\" or \"dir\" in order input>output")
    parser.add_argument("-dir", default="./", help="set ReM XML files input directory (\"./\" default)")
    parser.add_argument("-filename", default="stdin", help="set file name for input via stdin for output into a specific file")
    parser.add_argument("-FtimeGenre", default="False", help="set for marking time and genre of the source document on the file name (\"False\" default)")
    parser.add_argument("-files", default="all", help="filter list of ReM XML file names in ReM XML directory separated by whitespace (\"all\" by default) - e.g. \"M001-N1 M002-N1\"")
    parser.add_argument("-dest", default="./", help="set ReM CoNLL files output directory (\"./\" default)")
    parser.add_argument("-silent", default="False", help="set logging to silent (\"False\" default)")
    if len(sys.argv)==1:
        parser.print_help()
        sys.exit(1)
    args = parser.parse_args()

    logPath = "./"
    logFileName = "{0}_{1}".format(path.basename(__file__), str(time())[:9])
    initializeLogger(logPath, logFileName, loglevelFile = logging.DEBUG, loglevelConsole = logging.DEBUG, propagate = (args.silent == "False"))

    inoutMode = args.mode
    srcDir = args.dir #"../res/rem/data"
    outDir = args.dest #"../res/rem/conll"
    fileName = args.filename
    global fileNameTimeGenreFlag
    fileNameTimeGenreFlag = args.FtimeGenre

    if inoutMode.endswith("stdout"):
        outDir = sys.stdout
    if  inoutMode.startswith("stdin"):
        processSrcFile(sys.stdin, outDir, fileName)
    elif inoutMode.startswith("dir"):
        if args.files != "all":
            for f in args.files.split():
                if not f.endswith(".xml"):
                    f = f + ".xml"
                processSrcFile(srcDir, outDir, f)
        else:
            for file in listdir(srcDir):
                if file.lower().endswith(".xml"):
                    processSrcFile(srcDir, outDir, file)
    else:
        logger.critical("mode for input and output not set correctly")
