//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSCognitoAuthPlugin
import SwiftUI

/// The state observed by the Confirm Sign In with Custom Challenge and Confirm Sign In with MFA Code content views, representing the ``Authenticator`` is in either the ``AuthenticatorStep/confirmSignInWithCustomChallenge`` or the ``AuthenticatorStep/confirmSignInWithMFACode`` step accordingly.
public class ConfirmSignInWithCodeState: AuthenticatorBaseState {
    /// The confirmation code provided by the user
    @Published public var confirmationCode: String = ""

    override init(credentials: Credentials) {
        super.init(credentials: credentials)
    }

    init(authenticatorState: AuthenticatorStateProtocol) {
        super.init(authenticatorState: authenticatorState,
                   credentials: Credentials())
    }

    /// The `Amplify.AuthCodeDeliveryDetails` associated with this state. If the Authenticator is not in the `.confirmSignInWithMFACode` or `confirmSignInWithOTP` step, it returns `nil`
    public var deliveryDetails: AuthCodeDeliveryDetails? {
        switch authenticatorState.step {
        case .confirmSignInWithMFACode(let deliveryDetails),
                .confirmSignInWithOTP(let deliveryDetails):
            return deliveryDetails
        default:
            return nil
        }
    }

    /// Attempts to confirm the user's sign in using the provided confirmation code.
    ///
    /// Automatically sets the Authenticator's next step accordingly, as well as the
    /// ``AuthenticatorBaseState/isBusy`` and ``AuthenticatorBaseState/message`` properties.
    /// - Throws: An `Amplify.AuthenticationError` if the operation fails
    public func confirmSignIn() async throws {
        setBusy(true)

        do {
            log.verbose("Attempting to confirm Sign In with Code")
            let result = try await authenticationService.confirmSignIn(
                challengeResponse: confirmationCode,
                options: nil
            )
            let nextStep = try await nextStep(for: result)

            setBusy(false)

            authenticatorState.setCurrentStep(nextStep)
        } catch {
            log.error("Confirm Sign In with Code failed")
            let authenticationError = self.error(for: error)
            setMessage(authenticationError)
            throw authenticationError
        }
    }
}
