package GameComponents
{
	import GameComponents.Insignia.*;
	import GameComponents.MmoGirl.*;
	import GameComponents.Platforms.*;
	import GameComponents.Quiz.*;
	import GameComponents.TeleRecicla.*;
	import GameComponents.Video.*;

	import flash.geom.Point;
	import flash.net.registerClassAlias;
	import flash.utils.getQualifiedClassName;

	import mx.collections.ArrayCollection;

	import utils.Point3;


	/**
	 * Implementación concreta de enumeración de componentes. Aquí es donde hay que añadir los nuevos
	 * componentes a medida que se van creando.
	 */
	public final class GameComponentEnumerator implements IGameComponentEnumerator
	{
		public function GameComponentEnumerator()
		{
			// Aquí es donde añadimos las Classes de los componentes
			mComponentClasses.addItem(DefaultGameComponent as Class);
			mComponentClasses.addItem(TestGameComponent as Class);
			mComponentClasses.addItem(IsoComponent as Class);
			mComponentClasses.addItem(Render2DComponent as Class);
			mComponentClasses.addItem(Character as Class);
			mComponentClasses.addItem(CharacterGestureController as Class);
			mComponentClasses.addItem(NPC as Class);
			mComponentClasses.addItem(Interaction as Class);
			mComponentClasses.addItem(DisableInteraction as Class);
			mComponentClasses.addItem(Bso as Class);
			mComponentClasses.addItem(Door as Class);

			mComponentClasses.addItem(Vehicle as Class);

			// Registramos con el sistema de ActionScript Message Format (AMF)
			registerClassAlias(getQualifiedClassName(DefaultGameComponent), DefaultGameComponent);
			registerClassAlias(getQualifiedClassName(TestGameComponent), TestGameComponent);
			registerClassAlias(getQualifiedClassName(IsoComponent), IsoComponent);
			registerClassAlias(getQualifiedClassName(Render2DComponent), Render2DComponent);
			registerClassAlias(getQualifiedClassName(Character), Character);
			registerClassAlias(getQualifiedClassName(CharacterGestureController), CharacterGestureController);
			registerClassAlias(getQualifiedClassName(Interaction), Interaction);
			registerClassAlias(getQualifiedClassName(DisableInteraction), DisableInteraction);
			registerClassAlias(getQualifiedClassName(Door), Door);
			registerClassAlias(getQualifiedClassName(NPC), NPC);
			registerClassAlias(getQualifiedClassName(Bso), Bso);

			registerClassAlias(getQualifiedClassName(Vehicle), Vehicle);

			registerClassAlias(getQualifiedClassName(Point3), Point3);
			registerClassAlias(getQualifiedClassName(Point), Point);

			// Ahora los componentes por grupo
			RegisterVideo();
			RegisterQuiz();
			RegisterOpelInsignia();
			RegisterMmoGirl();
			RegisterPlatformsTest();
			RegisterTelerecicla();
		}

		private function RegisterVideo() : void
		{
			mComponentClasses.addItem(VideoController as Class);
			mComponentClasses.addItem(VideoContent as Class);
			mComponentClasses.addItem(VideoGizmo as Class);

			registerClassAlias(getQualifiedClassName(VideoController), VideoController);
			registerClassAlias(getQualifiedClassName(VideoContent), VideoContent);
			registerClassAlias(getQualifiedClassName(VideoGizmo), VideoGizmo);
		}

		private function RegisterMmoGirl() : void
		{
			mComponentClasses.addItem(PuestoHelados as Class);
			mComponentClasses.addItem(CityPuestoGlobos as Class);
			mComponentClasses.addItem(HallPuertaAscensor as Class);
			mComponentClasses.addItem(MmoTeleport as Class);
			mComponentClasses.addItem(CityChicaBolera as Class);
			mComponentClasses.addItem(ParquePuestoLimonada as Class);

			registerClassAlias(getQualifiedClassName(PuestoHelados), PuestoHelados);
			registerClassAlias(getQualifiedClassName(CityPuestoGlobos), CityPuestoGlobos);
			registerClassAlias(getQualifiedClassName(HallPuertaAscensor), HallPuertaAscensor);
			registerClassAlias(getQualifiedClassName(MmoTeleport), MmoTeleport);
			registerClassAlias(getQualifiedClassName(CityChicaBolera), CityChicaBolera);
			registerClassAlias(getQualifiedClassName(ParquePuestoLimonada), ParquePuestoLimonada);
		}

		private function RegisterPlatformsTest() : void
		{
			mComponentClasses.addItem(Platform as Class);
			mComponentClasses.addItem(PlatformCharacter as Class);

			registerClassAlias(getQualifiedClassName(Platform), Platform);
			registerClassAlias(getQualifiedClassName(PlatformCharacter), PlatformCharacter);
		}

		private function RegisterOpelInsignia() : void
		{
			mComponentClasses.addItem(OIGestureController as Class);
			mComponentClasses.addItem(OITutorialMain as Class);
			mComponentClasses.addItem(OIChica as Class);
			mComponentClasses.addItem(OIGameMain as Class);
			mComponentClasses.addItem(OIInterface as Class);
			mComponentClasses.addItem(OITrail as Class);
			mComponentClasses.addItem(OIBall as Class);
			mComponentClasses.addItem(OIOst as Class);
			mComponentClasses.addItem(OIQuizInterface as Class);

			registerClassAlias(getQualifiedClassName(OIGestureController), OIGestureController);
			registerClassAlias(getQualifiedClassName(OITutorialMain), OITutorialMain);
			registerClassAlias(getQualifiedClassName(OIChica), OIChica);
			registerClassAlias(getQualifiedClassName(OIGameMain), OIGameMain);
			registerClassAlias(getQualifiedClassName(OIInterface), OIInterface);
			registerClassAlias(getQualifiedClassName(OITrail), OITrail);
			registerClassAlias(getQualifiedClassName(OIBall), OIBall);
			registerClassAlias(getQualifiedClassName(OIOst), OIOst);
			registerClassAlias(getQualifiedClassName(OIQuizInterface), OIQuizInterface);
		}

		private function RegisterQuiz() : void
		{
			mComponentClasses.addItem(QuizController as Class);
			mComponentClasses.addItem(QuizAnswer as Class);
			mComponentClasses.addItem(QuizBackground as Class);
			mComponentClasses.addItem(QuizScore as Class);

			registerClassAlias(getQualifiedClassName(QuizController), QuizController);
			registerClassAlias(getQualifiedClassName(QuizAnswer), QuizAnswer);
			registerClassAlias(getQualifiedClassName(QuizBackground), QuizBackground);
			registerClassAlias(getQualifiedClassName(QuizScore), QuizScore);
		}

		private function RegisterTelerecicla() : void
		{
			mComponentClasses.addItem(EcoTrivialInterface as Class);

			mComponentClasses.addItem(AmarilloMain as Class);
			mComponentClasses.addItem(AmarilloGame as Class);
			mComponentClasses.addItem(AmarilloObject as Class);

			mComponentClasses.addItem(CaminosGame as Class);
			mComponentClasses.addItem(CaminosInterface as Class);

			mComponentClasses.addItem(HiddenGame as Class);
			mComponentClasses.addItem(HiddenClock as Class);
			mComponentClasses.addItem(HiddenInterface as Class);
			
			mComponentClasses.addItem(TelereciclaOst as Class);

			registerClassAlias(getQualifiedClassName(EcoTrivialInterface), EcoTrivialInterface);

			registerClassAlias(getQualifiedClassName(AmarilloMain), AmarilloMain);
			registerClassAlias(getQualifiedClassName(AmarilloGame), AmarilloGame);
			registerClassAlias(getQualifiedClassName(AmarilloObject), AmarilloObject);

			registerClassAlias(getQualifiedClassName(CaminosGame), CaminosGame);
			registerClassAlias(getQualifiedClassName(CaminosInterface), CaminosInterface);

			registerClassAlias(getQualifiedClassName(HiddenGame), HiddenGame);
			registerClassAlias(getQualifiedClassName(HiddenClock), HiddenClock);
			registerClassAlias(getQualifiedClassName(HiddenInterface), HiddenInterface);
			
			registerClassAlias(getQualifiedClassName(TelereciclaOst), TelereciclaOst);
		}

		public function GetComponentClasses() : ArrayCollection
		{
			return mComponentClasses;
		}

		public function GetComponentsDescription() : ArrayCollection
		{
			var ret : ArrayCollection = new ArrayCollection;

			for each (var cl : Class in mComponentClasses)
			{
				ret.addItem(GetDescription(cl));
			}

			return ret;
		}

		public function GetDescription(cl : Class) : Object
		{
			var name : String = getQualifiedClassName(cl);
			var idxShortNameStart : int = name.lastIndexOf("::");
			var shortName : String = name;
			if (idxShortNameStart != -1)
				shortName = name.substr(idxShortNameStart+2, name.length-idxShortNameStart-2);

			var middleNamespace : String = "";
			var middleStart : int = name.indexOf(".")+1;

			if (middleStart != 0)
			{
				var middleEnd : int = idxShortNameStart;
				middleNamespace = name.substr(middleStart, middleEnd-middleStart);
			}

			return {TheClass:cl, FullName:name, ShortName:shortName, MiddleNamespace:middleNamespace};
		}

		private var mComponentClasses : ArrayCollection = new ArrayCollection;
	}
}