module Main where

import Control.Parallel
  ( parTraverse
  )
import Data.Array
  ( (..)
  , catMaybes
  , concat
  , length
  )
import Data.Either
  ( Either(..)
  )
import Data.HTTP.Method
  ( Method(..)
  )
import Data.Int
  ( round
  )
import Data.Maybe
  ( maybe
  , Maybe
  )
import Data.Semiring
  ( (*)
  )
import Effect
  ( Effect
  )
import Effect.Aff
  ( launchAff
  , Fiber
  , Aff
  )
import Effect.Class
  ( liftEffect
  )
import Effect.Console
  ( log
  )
import Node.Encoding
  ( Encoding
      ( UTF8
      )
  )
import Prelude
  ( Unit
  , map
  , bind
  , show
  , div
  , discard
  , ($)
  , (>>>)
  , (>=>)
  , (<>)
  )

import Data.Argonaut.Core as J
import Foreign.Object as F
import Network.HTTP.Affjax as AX
import Network.HTTP.Affjax.Response as AXRes
import Network.HTTP.RequestHeader as H
import Node.FS.Aff as Fs

split ::
  Int ->
  Array Int
split i = map ((*) 100) $ 0 .. (div i 100)

decodeUserCount ::
  J.Json ->
  Int
decodeUserCount = (J.toObject >=> F.lookup "userCount" >=> J.toNumber) >>> maybe 0 round

decodeUsernames ::
  J.Json ->
  Array String
decodeUsernames = J.caseJsonArray [] (map (J.toObject >=> F.lookup "username" >=> J.toString) >>> catMaybes)

decodeEmail ::
  J.Json ->
  Maybe String
decodeEmail = J.toObject >=> F.lookup "email" >=> J.toString

fetchGitterMembers ::
  Int ->
  Aff (AX.AffjaxResponse J.Json)
fetchGitterMembers offset = AX.affjax AXRes.json (AX.defaultRequest { method = Left GET
                                                                    , url = "https://api.gitter.im/v1/rooms/???/users?limit=100&skip=" <> show offset
                                                                    , headers = [ H.RequestHeader "Authorization" "Bearer ???"
                                                                                ]
                                                                    })

fetchGithubUser ::
  String ->
  Aff (AX.AffjaxResponse J.Json)
fetchGithubUser username = AX.affjax AXRes.json (AX.defaultRequest { method = Left GET
                                                                   , url = "https://api.github.com/users/" <> username
                                                                   , headers = [ H.RequestHeader "Authorization" "token ???"
                                                                               ]
                                                                   })

fetchGitterRoom ::
  Aff (AX.AffjaxResponse J.Json)
fetchGitterRoom = AX.affjax AXRes.json (AX.defaultRequest { method = Left GET
                                                          , url = "https://api.gitter.im/v1/rooms/???"
                                                          , headers = [ H.RequestHeader "Authorization" "Bearer ???"
                                                                      ]
                                                          })

main ::
  Effect (Fiber Unit)
main = launchAff $ do
  res <- fetchGitterRoom
  offsets <- parTraverse fetchGitterMembers $ split $ decodeUserCount res.response
  let usernames = concat $ map (_.response >>> decodeUsernames) offsets
  liftEffect $ log $ "Members: " <> (show $ length usernames)
  ghReqs <- parTraverse fetchGithubUser usernames
  let emails = catMaybes $ map (_.response >>> decodeEmail) ghReqs
  let json = J.stringify $ J.fromArray $ map J.fromString emails
  Fs.writeTextFile UTF8 "./emails.json" json
  liftEffect $ log $ "Emails: " <> json
