{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}

module IO.HttpTest where

import ClassyPrelude

import Test.Tasty

import Brok.IO.Http      (check)
import Brok.Types.Config (defaultConfig)
import Brok.Types.Link   (Link (Link), LinkType (..), urlToLink)
import Brok.Types.RAIO   (mkApp)
import Test.Tasty.HUnit

testLink :: Text -> IO Link
testLink lnk = runReaderT (check 0 (urlToLink lnk)) (mkApp defaultConfig)

test_http :: TestTree
test_http =
    testGroup
        "Brok.IO.Http"
        [ testCase "Medium (409 with HEAD)" $ do
              result <-
                  testLink
                      "https://medium.freecodecamp.org/understanding-redux-the-worlds-easiest-guide-to-beginning-redux-c695f45546f6"
              assertEqual
                  "Returns a 200"
                  (Link
                       "https://medium.freecodecamp.org/understanding-redux-the-worlds-easiest-guide-to-beginning-redux-c695f45546f6"
                       (Working 200))
                  result
        , testCase "TutsPlus (Requires User-Agent Header)" $ do
              result <-
                  testLink
                      "https://code.tutsplus.com/tutorials/stateful-vs-stateless-functional-components-in-react--cms-29541"
              assertEqual
                  "Returns a 200"
                  (Link
                       "https://code.tutsplus.com/tutorials/stateful-vs-stateless-functional-components-in-react--cms-29541"
                       (Working 200))
                  result
        , testCase "Non-existent site" $ do
              result <- testLink "http://askdjfhaksjdhfkajsdfh.com"
              assertEqual
                  "Returns a 200"
                  (Link "http://askdjfhaksjdhfkajsdfh.com" ConnectionFailure)
                  result
        , testCase "Invalid URL" $ do
              result <- testLink "http://user:password&#64;securesite.com/secret-file.json&quot;"
              assertEqual
                  "Returns a 200"
                  (Link "http://user:password&#64;securesite.com/secret-file.json&quot;" InvalidURL)
                  result
        ]
