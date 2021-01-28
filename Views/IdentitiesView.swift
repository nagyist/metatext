// Copyright © 2020 Metabolist. All rights reserved.

import Kingfisher
import SwiftUI
import ViewModels

struct IdentitiesView: View {
    @StateObject var viewModel: IdentitiesViewModel
    @EnvironmentObject var rootViewModel: RootViewModel
    @Environment(\.displayScale) var displayScale: CGFloat

    var body: some View {
        Form {
            Section {
                NavigationLink(
                    destination: AddIdentityView(
                        viewModelClosure: { rootViewModel.addIdentityViewModel() },
                        displayWelcome: false),
                    label: {
                        Label("add", systemImage: "plus.circle")
                    })
            }
            section(title: "identities.accounts",
                    identities: viewModel.identities.filter { $0.authenticated && !$0.pending })
            section(title: "identities.browsing",
                    identities: viewModel.identities.filter { !$0.authenticated && !$0.pending })
            section(title: "identities.pending",
                    identities: viewModel.identities.filter { $0.pending })
        }
        .navigationTitle(Text("secondary-navigation.accounts"))
        .toolbar {
            ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                EditButton()
            }
        }
    }
}

private extension IdentitiesView {
    @ViewBuilder
    func section(title: LocalizedStringKey, identities: [Identity]) -> some View {
        if identities.isEmpty {
            EmptyView()
        } else {
            Section(header: Text(title)) {
                List {
                    ForEach(identities) { identity in
                        Button {
                            withAnimation {
                                rootViewModel.identitySelected(id: identity.id)
                            }
                        } label: {
                            row(identity: identity)
                        }
                        .disabled(identity.id == viewModel.currentIdentityId)
                        .buttonStyle(PlainButtonStyle())
                    }
                    .onDelete {
                        guard let index = $0.first else { return }

                        rootViewModel.deleteIdentity(id: identities[index].id)
                    }
                }
            }
        }
    }

    @ViewBuilder
    func row(identity: Identity) -> some View {
        HStack {
            Label {
                Text(verbatim: identity.handle)
            } icon: {
                KFImage(identity.image)
                    .downsampled(dimension: .barButtonItemDimension, scaleFactor: displayScale)
            }
            Spacer()
            if identity.id == viewModel.currentIdentityId {
                Image(systemName: "checkmark.circle")
            }
        }
    }
}

#if DEBUG
import PreviewViewModels

struct IdentitiesView_Previews: PreviewProvider {
    static var previews: some View {
        IdentitiesView(viewModel: .init(identityContext: .preview))
            .environmentObject(RootViewModel.preview)
    }
}
#endif
