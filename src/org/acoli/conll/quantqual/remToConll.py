# -*- coding: utf-8 -*-
"""
Created on 09.02.2017

@author: Benjamin Kosmehl

Convert REM xml files into conll format.

TODO: insert file meta information as comment into conll
"""
from lxml import etree  # @UnresolvedImport#
from time import time
from os import listdir, path, makedirs
import codecs
import argparse
import logging
import re

logger = logging.getLogger()

def processSrcFile(filePath, outDir):
    logger.info("processing %s", filePath)
    
    srcStuff = etree.parse(filePath)
    srcRoot = srcStuff.getroot()
    
    out = path.join(outDir, re.sub("\.[\w]{2,4}$", ".conll", path.basename(filePath)))
    makedirs(path.dirname(out), exist_ok=True)
    if path.isfile(out):
        open(out, "w").close()
    f = codecs.open(out, "a", "utf-8")
    sentenceBuffer = []
    
    # tags used below tok_anno
    tagz = ["norm", "lemma", "pos", "infl", "punc"]
    # column header
    line = u"#ID\tTID\tWORD\tLEMMA\tPOS\tINFL\tSB"
    
    sentenceBuffer.append(line)
    sentenceBuffer.append(u"")
    sentenceEndFlag = False
    sentenceInternalTokenID = 1
        
    for c in srcRoot:
        if c.tag == "token":
            
            tok_annos = [elem for elem in c.iter() if elem.tag == "tok_anno"]
            if not tok_annos:
                logger.critical("data structure corrupted at {0} line {1}", filePath, srcRoot.index(c))
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
                    line = line + "\t" + cv
                                
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

def initializeLogger(logPath, fileName, loglevelFile = logging.DEBUG, loglevelConsole = logging.INFO):
    logging.getLogger().setLevel(loglevelFile)
    logFormatter = logging.Formatter("%(asctime)s [%(threadName)-12.12s] [%(levelname)-7.7s]  %(message)s")
    rootLogger = logging.getLogger()
    
    fileHandler = logging.FileHandler("{0}/{1}.log".format(logPath, fileName))
    fileHandler.setFormatter(logFormatter)
    rootLogger.addHandler(fileHandler)
    
    consoleHandler = logging.StreamHandler()
    consoleHandler.setLevel(loglevelConsole)
    
    rootLogger.addHandler(consoleHandler)

if __name__ == "__main__":
    
    parser = argparse.ArgumentParser(description="Convert REM xml to conll format.")
    parser.add_argument("-dir", default="./", help="set REM xml files directory (\"./\" default)")
    parser.add_argument("-files", default="all", help="list of REM xml file names in REM xml directory separated by whitespace (all by default) - e.g. \"M001-N1 M002-N1\"")
    parser.add_argument("-dest", default="./", help="set REM conll files output directory (\"./\" default)")
    args = parser.parse_args()
    
    logPath = "./"
    fileName = "{0}_{1}".format(path.basename(__file__), str(time())[:9])
    initializeLogger(logPath, fileName, loglevelFile = logging.DEBUG, loglevelConsole = logging.DEBUG)
    
    srcDir = args.dir #"../res/rem/data"
    outDir = args.dest #"../res/rem/conll"
        
    
    if args.files != "all":
        for f in args.files.split():                
            processSrcFile(path.join(srcDir, f), outDir)
    else:
        for file in listdir(srcDir):  
            if file.lower().endswith(".xml"):
                processSrcFile(path.join(srcDir, file), outDir)


    