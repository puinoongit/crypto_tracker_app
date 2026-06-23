/// Stable [Hero] tags shared across screens so widgets can morph into each
/// other during navigation. Centralized to guarantee both endpoints agree.
String coinAvatarHeroTag(String coinId) => 'coin-avatar-$coinId';
